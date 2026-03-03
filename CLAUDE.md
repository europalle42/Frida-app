# CLAUDE.md – Frida App

## Projekt

Frida er en digital garderobe-app til iOS med AI virtual try-on.
Dokumentation og kravspecifikation — koden udvikles i Xcode.

## GitHub

- Repo: https://github.com/europalle42/Frida-app
- Branch: main

## Teknologi

- Platform: iOS 17+
- Sprog: Swift 5.9+
- Framework: SwiftUI + SwiftData + ARKit + Vision + Core ML
- Arkitektur: MVVM
- AI Backend: CatVTON (primaer), HF Spaces (fallback)
- Dependencies: Ingen (kun Apple frameworks)

## Filstruktur

```
Frida-app/
  CLAUDE.md              — Denne fil (serverinstruktioner)
  CHANGELOG.md           — Aendringslog
  KRAVSPECIFIKATION.md   — Features, datamodeller, roadmap
  RESEARCH-AI-TRYON.md   — AI virtual try-on research
  README.md              — GitHub readme
```

## App-features

### 4 tabs
1. **Garderobe** — Tilfoej/vis toj (grid, filtrering, soegning)
2. **Styling** — Byg outfits med layer-system (7 lag)
3. **Mine Outfits** — Gemte outfits (liste, swipe-to-delete)
4. **Try-On** — AI virtual try-on (selfie + toj = resultat)

### AI Virtual Try-On
- On-device: Vision (body pose), Person Segmentation, ARKit
- Cloud: CatVTON (self-hosted), HF Spaces, Gemini API
- Se `RESEARCH-AI-TRYON.md` for detaljer

### 7 kategorier
Tops, Bukser, Nederdele, Kjoler, Jakker, Sko, Accessories

### Datamodeller
- GarmentItem (SwiftData) — tojstykke med kategori, billede, tags, worn-count
- Outfit (SwiftData) — samling af garments med states og layers
- GarmentState (struct) — position, openness, rolled

## Vigtige regler
- Dokumentation skrives paa dansk
- Kode-kommentarer paa engelsk
- CHANGELOG.md opdateres ved hver aendring
