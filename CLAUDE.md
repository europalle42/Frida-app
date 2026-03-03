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
  CLAUDE.md                          — Denne fil
  CHANGELOG.md                       — Aendringslog
  KRAVSPECIFIKATION.md               — Features, datamodeller, roadmap
  RESEARCH-AI-TRYON.md               — AI virtual try-on research
  .gitignore                         — Git ignore regler
  Frida/
    FridaApp.swift                   — App entry point (@main, SwiftData container)
    ContentView.swift                — Tab navigation (4 tabs)
    Models/
      GarmentItem.swift              — GarmentItem model + enums (category, layer)
      Outfit.swift                   — Outfit model + GarmentState
      TryOnResult.swift              — TryOnResult model
    ViewModels/
      WardrobeViewModel.swift        — Garderobe logik (filter, soeg, CRUD)
      StylingViewModel.swift         — Outfit builder logik (layers)
      TryOnViewModel.swift           — Try-on flow (state machine)
    Views/
      Wardrobe/WardrobeView.swift    — Garderobe grid + tilfoej toej
      Styling/StylingView.swift      — Outfit builder
      Outfits/OutfitsView.swift      — Gemte outfits liste
      TryOn/TryOnView.swift          — Virtual try-on (foto→AI→resultat)
      Components/
        GarmentCard.swift            — Toej-kort (grid item)
        CategoryFilterBar.swift      — Kategori-filter chips
        CameraView.swift             — UIKit kamera wrapper
        ColorExtension.swift         — Color hex extension
    Services/
      TryOnAPIService.swift          — HF Spaces + Gemini API integration
    Assets.xcassets/                 — App ikon, farver
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
- TryOnResult (SwiftData) — try-on resultat med person/toej/resultat billeder
- GarmentState (struct) — position, openness, rolled

### Try-On Providers
- Kolors-VTON (HF Spaces, gratis)
- IDM-VTON (HF Spaces, gratis)
- Google Gemini (API key paakraevet)

## Vigtige regler
- Dokumentation skrives paa dansk
- Kode-kommentarer paa engelsk
- CHANGELOG.md opdateres ved hver aendring
