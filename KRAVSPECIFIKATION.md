# Frida - Digital Garderobe App

## Oversigt

Frida er en iOS-app til styring af din garderobe. Du kan registrere dit toj, bygge outfits og gemme dem til senere.

**Platform:** iOS (iPhone)
**Teknologi:** SwiftUI + SwiftData
**Arkitektur:** MVVM

---

## Funktioner

### 1. Garderobe (Tab 1)

Overblik over alt toj i garderoben.

- Tilfoej nyt toj med navn og kategori
- Vis toj i et grid med emoji-ikoner
- Filtrer efter kategori
- Soeg efter navn
- Sorteret efter nyeste foerst

**Kategorier:**
| Kategori | Emoji | Layer |
|----------|-------|-------|
| Tops | 👕 | Top |
| Bukser | 👖 | Bottom |
| Nederdele | 👗 | Bottom |
| Kjoler | 👗 | Top |
| Jakker | 🧥 | Outerwear |
| Sko | 👟 | Shoes |
| Accessories | 👜 | Accessories |

### 2. Styling (Tab 2)

Byg outfits ved at vaelge toj fra garderoben.

- Visuel model/silhouet (👤)
- Scroll horisontalt igennem tilgaengeligt toj
- Klik for at tilfoeje til outfit
- Automatisk layer-haandtering (kun ét item per layer)
- Fjern enkelt-items med X-knap
- "Ryd" knap for at starte forfra
- "Gem Outfit" med navn

**Layer-system (z-index):**
1. Base (0)
2. Bottom (1) — bukser, nederdele
3. Top (2) — tops, kjoler
4. Mid-layer (3)
5. Outerwear (4) — jakker
6. Accessories (5)
7. Shoes (6)

### 3. Mine Outfits (Tab 3)

Liste over gemte outfits.

- Vis outfit-navn, emoji-ikoner og dato
- Swipe-to-delete
- Sorteret efter oprettelsesdato

---

## Datamodeller

### GarmentItem (SwiftData)
| Felt | Type | Beskrivelse |
|------|------|-------------|
| id | UUID | Unik ID |
| name | String | Navn paa toejstykke |
| category | GarmentCategory | Kategori (enum) |
| imageData | Data? | Billede (v2) |
| maskData | Data? | Maske til billede (v2) |
| dominantColor | String? | Dominant farve (v2) |
| tags | [String] | Tags/labels |
| timesWorn | Int | Antal gange brugt |
| lastWorn | Date? | Sidst brugt dato |
| createdDate | Date | Oprettelsesdato |

### Outfit (SwiftData)
| Felt | Type | Beskrivelse |
|------|------|-------------|
| id | UUID | Unik ID |
| name | String | Outfit-navn |
| garmentItems | [GarmentItem] | Toj i outfittet |
| garmentStates | [String: Data] | Position/state per item |
| garmentLayers | [String: Int] | Layer per item |
| createdDate | Date | Oprettelsesdato |
| tags | [String] | Tags/labels |
| rating | Int? | Bedoemmelse |

### GarmentState (struct)
| Felt | Type | Beskrivelse |
|------|------|-------------|
| position | GarmentPosition | Standard / I bukser / Ude |
| openness | Double | 0.0 lukket — 1.0 aaben |
| rolled | Bool | Oprullede aermer/bukser |

---

## Nuvaerende status (v1)

**Implementeret:**
- SwiftData persistence
- Garderobe CRUD
- Outfit builder med layer-system
- MVVM arkitektur
- Ingen externe dependencies

**Planlagt til v2:**
- Kamera/billede-upload af toj
- Advanced model-rendering (visuelt paa en figur)
- Image processing og farveudtraek
- Komplekst state-system (position, openness, rolled)
- Outfit-forslag baseret paa vejr/lejlighed
- Statistik (mest brugte items, outfit-frekvens)

---

## Filstruktur

```
frida/
  fridaApp.swift          — App entry point (@main)
  ContentView.swift       — Tab navigation (3 tabs)
  Models.swift            — Datamodeller + enums
  ViewModels.swift        — WardrobeViewModel, StylingViewModel
  WardrobeView.swift      — Garderobe-grid + tilfoej toj
  StylingView.swift       — Outfit builder
  OutfitsView.swift       — Gemte outfits liste
```

---

## Krav til udvikling

- Xcode 15+
- iOS 17+ (SwiftData krav)
- Swift 5.9+
- Ingen CocoaPods/SPM dependencies
