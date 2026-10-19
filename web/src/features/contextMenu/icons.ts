// Thin-line theme: resources keep sending Font Awesome icons ("fa-solid fa-car"...), the menu shows the
// matching Tabler icon instead (font loaded in index.html). An icon already given as Tabler ("ti ti-xxx")
// is kept as is; an icon with no match here stays Font Awesome.
const FA_VERS_TABLER: Record<string, string> = {
  // people / interactions
  "user": "user", "circle-user": "user-circle", "user-check": "user-check", "user-shield": "user-shield",
  "user-secret": "spy", "user-tag": "tag", "user-doctor": "stethoscope", "user-clock": "user-exclamation",
  "user-large-slash": "user-off", "users": "users", "people-group": "users-group", "person": "man",
  "person-walking": "walk", "person-walking-arrow-right": "walk", "person-walking-arrow-loop-left": "walk",
  "person-rifle": "user-exclamation", "person-falling": "arrow-down-bar", "person-arrow-down-to-line": "arrow-down-bar",
  "person-rays": "accessible", "people-carry-box": "arrow-ramp-right-2", "hands-holding-child": "baby-carriage",
  "hand": "hand-stop", "hand-paper": "hand-stop", "hand-fist": "hand-grab", "hand-back-fist": "hand-grab",
  "hand-holding": "hand-move", "hand-holding-dollar": "cash", "hand-holding-usd": "cash",
  "hand-holding-medical": "first-aid-kit", "hand-pointer": "hand-click", "hand-point-up": "hand-finger",
  "hand-sparkles": "sparkles", "hands": "hand-two-fingers", "handcuffs": "link", "face-dizzy": "mood-crazy-happy",
  "face-smile": "mood-smile", "face-flushed": "mood-surprised", "skull": "skull", "mask": "masks-theater",
  "shirt": "shirt", "tshirt": "shirt", "shoe-prints": "shoe", "id-card": "id", "id-badge": "id-badge",
  "fingerprint": "fingerprint", "heart-pulse": "heartbeat", "bed": "bed", "bed-pulse": "bed",
  "wheelchair": "wheelchair", "wheelchair-move": "wheelchair",
  // search / info
  "magnifying-glass": "search", "search": "search", "eye": "eye", "eye-slash": "eye-off",
  "circle-info": "info-circle", "info-circle": "info-circle", "circle-question": "help-circle", "question": "help",
  "circle-exclamation": "alert-circle", "triangle-exclamation": "alert-triangle", "circle-check": "circle-check",
  "check": "check", "circle-xmark": "circle-x", "xmark": "x", "ban": "ban", "hashtag": "hash",
  "list": "list", "clipboard": "clipboard", "clipboard-list": "clipboard-list", "note-sticky": "note",
  "folder": "folder", "newspaper": "news", "file-pen": "file-pencil", "file-invoice-dollar": "file-invoice",
  "receipt": "receipt", "pen": "pencil", "pen-to-square": "edit", "tag": "tag", "bell": "bell",
  "star": "star", "flag": "flag", "gift": "gift", "clock": "clock", "clock-rotate-left": "history",
  "hourglass-half": "hourglass", "spinner": "loader-2", "circle-notch": "loader-2", "circle": "circle",
  "bug": "bug", "plus": "plus", "layer-group": "stack-2", "cube": "cube", "cubes": "packages",
  "vector-square": "vector", "ruler-horizontal": "ruler", "grip-lines": "grip-horizontal",
  "up-down-left-right": "arrows-move", "compress": "arrows-minimize", "window-maximize": "app-window",
  "arrows-rotate": "refresh", "rotate": "rotate", "arrow-right": "arrow-right", "arrow-left": "arrow-left",
  "arrow-up": "arrow-up", "arrow-down": "arrow-down", "angle-left": "chevron-left",
  "right-from-bracket": "logout", "sign-in-alt": "login", "power-off": "power", "play": "player-play",
  "pause": "player-pause", "bolt": "bolt", "lightbulb": "bulb", "plug": "plug",
  // doors / keys / security
  "lock": "lock", "lock-open": "lock-open", "unlock": "lock-open", "key": "key", "door-open": "door-enter",
  "door-closed": "door", "link": "link", "link-slash": "link-off", "unlink": "unlink", "shield": "shield",
  "shield-halved": "shield-half", "shield-alt": "shield", "vault": "lock-square", "dungeon": "building-castle",
  "elevator": "elevator", "building-shield": "building-bank", "building-columns": "building-bank",
  "university": "building-bank", "building": "building", "city": "building-skyscraper", "house": "home",
  "warehouse": "building-warehouse", "store": "building-store", "shop": "building-store",
  // vehicles
  "car": "car", "car-side": "car", "car-burst": "car-crash", "car-crash": "car-crash", "car-wash": "droplet",
  "truck-pickup": "truck", "truck-tow": "truck", "truck-ramp-box": "truck-loading", "truck-field": "truck",
  "truck-fast": "truck-delivery", "van-shuttle": "bus", "ambulance": "ambulance", "bicycle": "bike",
  "plane": "plane", "plane-departure": "plane-departure", "ship": "ship", "anchor": "anchor",
  "anchor-circle-xmark": "anchor-off", "train": "train", "gas-pump": "gas-station", "gauge-high": "gauge",
  "square-parking": "parking", "road": "road", "map-pin": "map-pin", "location-dot": "map-pin",
  "map-location-dot": "map-2", "tower-cell": "antenna", "tower-broadcast": "broadcast",
  // tools
  "screwdriver-wrench": "tool", "wrench": "tool", "tools": "tools", "toolbox": "tools", "screwdriver": "tool",
  "hammer": "hammer", "scissors": "scissors", "broom": "brush", "brush": "brush", "bucket": "bucket",
  "spray-can-sparkles": "spray", "fill-drip": "bucket-droplet", "palette": "palette", "trash": "trash",
  "dumpster": "trash", "box": "box", "box-open": "box", "box-archive": "archive", "boxes-stacked": "packages",
  "box-circle-check": "package", "briefcase": "briefcase", "jar": "bottle", "camera": "camera", "video": "video",
  "film": "movie", "tv": "device-tv", "desktop": "device-desktop", "laptop": "device-laptop",
  "laptop-code": "device-laptop", "computer-mouse": "mouse", "keyboard": "keyboard", "microchip": "cpu",
  "phone": "phone", "music": "music", "volume-high": "volume", "volume-xmark": "volume-off",
  // weapons / illegal
  "gun": "target", "crosshairs": "crosshair", "bomb": "bomb", "fire": "flame", "cannabis": "plant",
  "seedling": "seeding", "flask": "flask", "flask-vial": "flask-2", "vial": "test-pipe", "mortar-pestle": "bowl",
  "smoking": "smoking", "dice": "dice", "gem": "diamond",
  // money / shops
  "money-bill": "cash", "money-bill-wave": "cash-banknote", "dollar-sign": "currency-dollar", "coins": "coins",
  "sack-dollar": "pig-money", "sack-xmark": "pig-off", "credit-card": "credit-card", "cart-shopping": "shopping-cart",
  "shopping-basket": "basket", "bag-shopping": "shopping-bag",
  // medical
  "kit-medical": "first-aid-kit", "briefcase-medical": "first-aid-kit", "stethoscope": "stethoscope",
  "syringe": "vaccine", "pills": "pill", "tablets": "pill", "capsules": "pill", "bandage": "bandage",
  "hospital": "building-hospital", "staff-snake": "medical-cross", "scalpel": "cut", "droplet": "droplet",
  "temperature-high": "temperature", "temperature-three-quarters": "temperature",
  // misc
  "chair": "armchair", "couch": "sofa", "utensils": "tools-kitchen-2", "mug-saucer": "coffee", "fish": "fish",
  "weight-scale": "scale", "gear": "settings", "gears": "settings", "sliders": "adjustments",
  "comment": "message", "message": "message", "microphone": "microphone",
};

// Final CSS class of an icon sent by a resource.
export function iconClass(icon?: string): string | undefined {
  if (!icon) return undefined;
  if (/(^|\s)ti(\s|$)/.test(icon)) return icon;
  const m = icon.match(/fa-(?!solid\b|regular\b|brands\b|light\b|fw\b)([a-z0-9-]+)/g);
  if (m) {
    for (const c of m) {
      const t = FA_VERS_TABLER[c.slice(3)];
      if (t) return `ti ti-${t}`;
    }
  }
  return icon;
}

export const TABLER_NAMES = Object.values(FA_VERS_TABLER);
