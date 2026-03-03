# CLAUDE.md – Frida App

## Projekt

Frida er en digital garderobe-app til iOS (SwiftUI + SwiftData).
Dokumentation og kravspecifikation — koden udvikles i Xcode.

## GitHub

- Repo: https://github.com/europalle42/Frida-app
- Branch: main

## Teknologi

- Platform: iOS 17+
- Sprog: Swift 5.9+
- Framework: SwiftUI + SwiftData
- Arkitektur: MVVM
- Dependencies: Ingen

## Filstruktur

```
Frida-app/
  CLAUDE.md              — Denne fil (serverinstruktioner)
  CHANGELOG.md           — Aendringslog
  KRAVSPECIFIKATION.md   — Features, datamodeller, roadmap
  README.md              — GitHub readme
```

## App-features (v1)

### 3 tabs
1. **Garderobe** — Tilfoej/vis toj (grid, filtrering, soegning)
2. **Styling** — Byg outfits med layer-system (7 lag)
3. **Mine Outfits** — Gemte outfits (liste, swipe-to-delete)

### 7 kategorier
Tops, Bukser, Nederdele, Kjoler, Jakker, Sko, Accessories

### Datamodeller
- GarmentItem (SwiftData) — tojstykke med kategori, billede, tags, worn-count
- Outfit (SwiftData) — samling af garments med states og layers
- GarmentState (struct) — position, openness, rolled

## Planlagt (v2)
- Kamera/billede-upload
- Avanceret model-rendering
- Image processing + farveudtraek
- Outfit-forslag (vejr/lejlighed)
- Statistik

## Vigtige regler
- Dokumentation skrives paa dansk
- Kode-kommentarer paa engelsk
- CHANGELOG.md opdateres ved hver aendring
