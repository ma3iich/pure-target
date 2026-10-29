import "./style.scss";
import React, { useEffect, useLayoutEffect, useState, useRef, useCallback } from "react";
import { useNuiEvent } from "@/hook/nuiEvent";
import { fetchNui } from "@/hook/fetchNui";
import { isEnvBrowser } from "@/utils/misc";
import { setClipboard } from "@/utils/clipboard";
import { iconClass } from "./icons";

interface MenuItem {
  id: number;
  name?: string;
  icon?: string;
  value?: string;
  description?: string;
  header?: boolean;
  separator?: boolean;
  checked?: boolean;
  checkable?: boolean;
  disabled?: boolean;
  keepOpen?: boolean;
  style?: { color?: [number, number, number] };
  child?: MenuItem[];
}

function safeParseItems(items: unknown): MenuItem[] {
  if (Array.isArray(items)) return items;
  if (typeof items === "string") {
    try { const p = JSON.parse(items); return Array.isArray(p) ? p : []; }
    catch { return []; }
  }
  return [];
}

// The whole menu is always on screen, without pages or scrollbars: a list taller than the screen is split
// into columns (fitList). The menu never goes off screen.
const MARGIN = 8;        // minimum gap kept with the screen edge
const SUB_GAP = 8;       // gap between an item and its submenu (see style.scss)
const SUB_UP = 5;        // the submenu starts 5 px above its item (same)

// List taller than the screen: options laid out in columns (grid, class ctx-cols), as many rows as fit.
// Reset to one column first, to measure its real height.
function fitList(ul: HTMLElement | null) {
  if (!ul) return;
  ul.classList.remove("ctx-cols");
  ul.style.gridTemplateRows = "";
  const H = window.innerHeight - 2 * MARGIN;
  if (ul.offsetHeight <= H) return;
  const rows = Array.from(ul.children).filter(c => (c as HTMLElement).classList.contains("ctx-item")) as HTMLElement[];
  if (!rows.length) return;
  const rowH = Math.max(...rows.map(r => r.offsetHeight)) + 2; // + margins (1px top and bottom)
  const perCol = Math.max(1, Math.floor((H - 8) / rowH));
  ul.classList.add("ctx-cols");
  ul.style.gridTemplateRows = `repeat(${perCol}, auto)`;
}

// Moves an item's submenu when it does not fit: to the left when the right edge is too close, up when it
// overflows at the bottom. Sizes come from offsetWidth/Height (not affected by CSS transform animations).
function fitSubmenu(li: HTMLElement) {
  const sub = li.querySelector<HTMLElement>(":scope > .ctx-submenu");
  if (!sub) return;
  const hidden = getComputedStyle(sub).display === "none";
  if (hidden) sub.style.display = "block";
  sub.style.top = "";
  fitList(sub.querySelector<HTMLElement>(":scope > .ctx-list"));
  const liR = li.getBoundingClientRect();
  const w = sub.offsetWidth, h = sub.offsetHeight;
  const W = window.innerWidth, H = window.innerHeight;

  // A submenu whose parent already opened on the left keeps going left (otherwise it would cover the
  // main menu). Right by default.
  li.classList.remove("ctx-flip-x");
  const parentFlipped = !!li.parentElement?.closest(".ctx-item.ctx-flip-x");
  const roomRight = liR.right + SUB_GAP + w + MARGIN <= W;
  const roomLeft = liR.left - SUB_GAP - w >= MARGIN;
  const flip = parentFlipped ? roomLeft : (!roomRight && roomLeft);
  li.classList.toggle("ctx-flip-x", flip);

  let top = liR.top - SUB_UP;
  if (top + h + MARGIN > H) top = H - MARGIN - h;
  if (top < MARGIN) top = MARGIN;
  sub.style.top = `${Math.round(top - liR.top)}px`;

  if (hidden) sub.style.display = "";
}

const ContextMenu: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [menuData, setMenuData] = useState<MenuItem[]>([]);
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [checkedMap, setCheckedMap] = useState<Record<number, boolean>>({});
  const [hoveredDesc, setHoveredDesc] = useState<string | null>(null);
  const [descAbove, setDescAbove] = useState(false);
  const descRef = useRef<HTMLDivElement>(null);
  const mockDataRef = useRef<MenuItem[]>([]);
  const anchorRef = useRef<HTMLDivElement>(null);
  const clickPosRef = useRef({ x: 0, y: 0 });
  const visibleRef = useRef(false);
  // A click is being handled (action not finished yet): other clicks wait.
  const pendingRef = useRef(false);
  const BROWSER = isEnvBrowser();

  const reset = () => {
    setMenuData([]);
    setHoveredDesc(null);
  };

  useNuiEvent<boolean>("nui:context-menu:visible", (status) => {
    visibleRef.current = status;
    pendingRef.current = false;
    setVisible(status);
    if (!status) { reset(); mockDataRef.current = []; }
  });

  // The menu stays open after a click. If the option opens another window that takes the mouse (inventory,
  // ox_lib menu, phone...), FiveM gives the focus to THAT page and ours loses it (blur event): the menu closes.
  // 100 ms delay: FiveM gives the focus back by itself to a page that lost it without another one taking it.
  useEffect(() => {
    if (BROWSER) return;
    const onBlur = () => {
      if (!visibleRef.current) return;
      window.setTimeout(() => {
        if (!visibleRef.current || document.hasFocus()) return;
        visibleRef.current = false;
        reset();
        fetchNui("ContextMenuClose");
      }, 100);
    };
    window.addEventListener("blur", onBlur);
    return () => window.removeEventListener("blur", onBlur);
  }, [BROWSER]);

  useNuiEvent<MenuItem[]>("nui:context-menu:setData", (data) => {
    mockDataRef.current = safeParseItems(data);
  });

  const handleRightClick = useCallback(async (e: MouseEvent) => {
    if (!visible) return;
    e.preventDefault();

    let items: MenuItem[];
    if (BROWSER) {
      items = mockDataRef.current;
    } else {
      const raw = await fetchNui<MenuItem[] | string>("ContextMenuPosition", { x: e.clientX, y: e.clientY });
      items = safeParseItems(raw);
    }

    if (!items.length) return;

    clickPosRef.current = { x: e.clientX, y: e.clientY };
    const init: Record<number, boolean> = {};
    const initChecked = (list: MenuItem[]) => {
      list.forEach(item => {
        if (item.checkable) init[item.id] = item.checked ?? false;
        if (item.child) initChecked(item.child);
      });
    };
    initChecked(items);
    setCheckedMap(init);
    setMenuData(items);

    setPosition({ x: e.clientX, y: e.clientY });
  }, [visible, BROWSER]);

  // Main menu moved back on screen BEFORE it is painted (useLayoutEffect), measured with offsetWidth/Height:
  // the opening animation (scale 0.96) would make getBoundingClientRect wrong.
  useLayoutEffect(() => {
    if (!menuData.length) return;
    const el = anchorRef.current;
    if (!el) return;
    fitList(el.querySelector<HTMLElement>(":scope > .ctx-list"));

    const width = el.offsetWidth, height = el.offsetHeight;
    const W = window.innerWidth, H = window.innerHeight;

    setPosition(prev => {
      let x = prev.x, y = prev.y;
      if (x + width + MARGIN > W) x = W - width - MARGIN;
      if (y + height + MARGIN > H) y = H - height - MARGIN;
      if (x < MARGIN) x = MARGIN;
      if (y < MARGIN) y = MARGIN;
      return x === prev.x && y === prev.y ? prev : { x, y };
    });
  }, [menuData]);

  // Description tooltip: above the menu when it would go off screen below it.
  useLayoutEffect(() => {
    const el = descRef.current;
    if (!el) { setDescAbove(false); return; }
    const h = el.offsetHeight;
    const anchor = anchorRef.current;
    if (!anchor) return;
    const a = anchor.getBoundingClientRect();
    // theoretical position below, whether the tooltip is already above or not
    const bottomIfBelow = a.bottom + 4 + h;
    setDescAbove(bottomIfBelow + MARGIN > window.innerHeight && a.top - 4 - h >= MARGIN);
  }, [hoveredDesc, position]);

  const handleClickOutside = useCallback(() => {
    if (visible && menuData.length > 0) {
      reset();
      if (!BROWSER) fetchNui("ContextMenuClose");
    }
  }, [visible, menuData, BROWSER]);

  useEffect(() => {
    window.addEventListener("contextmenu", handleRightClick);
    window.addEventListener("click", handleClickOutside);
    return () => {
      window.removeEventListener("contextmenu", handleRightClick);
      window.removeEventListener("click", handleClickOutside);
    };
  }, [handleRightClick, handleClickOutside]);

  const handleItemClick = (item: MenuItem, e: React.MouseEvent) => {
    if (item.header || item.separator || item.disabled || item.child) return;
    e.stopPropagation();

    if (item.checkable) {
      const next = !checkedMap[item.id];
      setCheckedMap(prev => ({ ...prev, [item.id]: next }));
      if (!BROWSER) fetchNui("ContextMenuCheckToggle", { id: item.id, checked: next });
      return;
    }

    if (item.value) { setClipboard(item.value); return; }

    if (BROWSER) { reset(); return; }

    // keepOpen + menu key still held: the menu stays and refreshes (e.g. "Open" -> "Close").
    if (item.keepOpen) {
      // One action at a time (otherwise a double click would run a long action twice).
      if (pendingRef.current) return;
      pendingRef.current = true;
      fetchNui<{ keepOpen?: boolean } | string>("ContextMenuButtonClick", { id: item.id, keepOpen: true }).then((raw) => {
        pendingRef.current = false;
        let res: { keepOpen?: boolean } = {};
        if (typeof raw === "string") { try { res = JSON.parse(raw); } catch { res = {}; } } else if (raw) res = raw;
        if (!res.keepOpen) { reset(); return; }
        // give the action (and the server) time to apply, then refresh
        window.setTimeout(async () => {
          if (!visibleRef.current) return; // key released in the meantime
          const pos = clickPosRef.current;
          const fresh = safeParseItems(await fetchNui<MenuItem[] | string>("ContextMenuPosition", pos));
          if (!visibleRef.current) return;
          if (!fresh.length) { reset(); return; }
          const init: Record<number, boolean> = {};
          const initChecked = (list: MenuItem[]) => list.forEach(i => {
            if (i.checkable) init[i.id] = i.checked ?? false;
            if (i.child) initChecked(i.child);
          });
          initChecked(fresh);
          setCheckedMap(init);
          setMenuData(fresh);
        }, 350);
      }).catch(() => { pendingRef.current = false; reset(); });
      return;
    }

    fetchNui("ContextMenuButtonClick", { id: item.id });
    reset();
  };

  const renderMenu = (items: MenuItem[], depth = 0): React.ReactNode => {
    const safe = safeParseItems(items);
    if (!safe.length) return null;

    const header = safe.find(i => i.header);
    const body = safe.filter(i => !i.header);

    return (
      <ul className="ctx-list">
        {header && (
          <li className="ctx-header">
            {header.icon && <i className={iconClass(header.icon)} />}
            <span>{header.name}</span>
          </li>
        )}

        {body.map((item, idx) => {
          if (item.separator) return <li key={`sep-${idx}`} className="ctx-sep" />;

          const rgb = item.style?.color;
          const accent = rgb ? `rgb(${rgb[0]},${rgb[1]},${rgb[2]})` : undefined;
          const isChecked = checkedMap[item.id] ?? false;

          return (
            <li
              key={item.id}
              className={`ctx-item${item.child ? " ctx-has-child" : ""}${item.disabled ? " ctx-disabled" : ""}`}
              style={accent ? { "--accent": accent } as React.CSSProperties : {}}
              onClick={e => handleItemClick(item, e)}
              onMouseEnter={e => {
                setHoveredDesc(item.description ?? null);
                if (item.child) fitSubmenu(e.currentTarget);
              }}
              onMouseLeave={() => setHoveredDesc(null)}
            >
              <span className="ctx-icon">{item.icon && <i className={iconClass(item.icon)} />}</span>
              <span className="ctx-label">{item.name}</span>

              {item.value && <span className="ctx-badge">{item.value}</span>}

              {item.checkable && (
                <span className={`ctx-check${isChecked ? " is-checked" : ""}`}>
                  {isChecked && <i className="ti ti-check" />}
                </span>
              )}

              {item.child && (
                <span className="ctx-arrow"><i className="ti ti-chevron-right" /></span>
              )}

              {item.child && (
                <div className="ctx-submenu">
                  {renderMenu(item.child, depth + 1)}
                </div>
              )}
            </li>
          );
        })}

      </ul>
    );
  };

  if (!visible) return null;

  return (
    <div className="ctx-root">
      {menuData.length > 0 && (
        <div ref={anchorRef} className="ctx-anchor" style={{ top: position.y, left: position.x }}>
          {renderMenu(menuData)}
          {hoveredDesc && (
            <div ref={descRef} className={`ctx-desc${descAbove ? " ctx-desc-above" : ""}`}>
              <i className="ti ti-info-circle" />
              <span>{hoveredDesc}</span>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default ContextMenu;
