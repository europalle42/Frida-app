# Changelog – Frida App

## 2026-03-03

### Tilføjet
- Oprettet GitHub repo: https://github.com/europalle42/Frida-app
- `KRAVSPECIFIKATION.md` — samlet dokumentation fra eksisterende kode
  - 3 tabs (Garderobe, Styling, Mine Outfits)
  - 7 kategorier med layer-system
  - Datamodeller (GarmentItem, Outfit, GarmentState)
  - v2 roadmap
- `CLAUDE.md` — projektinstruktioner
- `CHANGELOG.md` — denne fil

### Tilfojet (AI Virtual Try-On research)
- `RESEARCH-AI-TRYON.md` — komplet research af open source AI try-on
  - 6 AI-modeller evalueret: CatVTON, IDM-VTON, OOTDiffusion, OmniTry, MV-VTON, Kolors-VTON
  - CatVTON anbefalet som primaer (ICLR 2025, <8 GB VRAM)
  - Apple frameworks: Vision, ARKit, RealityKit, Core ML, Person Segmentation
  - Gratis API'er: Hugging Face Spaces, Google Gemini, self-hosted CatVTON
  - Arkitekturdiagram for iOS-integration
- Opdateret `KRAVSPECIFIKATION.md` med ny Tab 4 (Virtual Try-On)
- Opdateret `CLAUDE.md` med AI tech stack

### Tilfojet (komplet Swift kodebase)
- Fuld iOS app i `Frida/` mappen (klar til Xcode-projekt)
- **App:** FridaApp.swift (entry point), ContentView.swift (4 tabs)
- **Models:** GarmentItem, Outfit, TryOnResult (alle SwiftData)
- **ViewModels:** WardrobeViewModel, StylingViewModel, TryOnViewModel
- **Views:**
  - Tab 1: WardrobeView — grid med kategori-filter, soegning, foto-upload
  - Tab 2: StylingView — outfit builder med layer-system
  - Tab 3: OutfitsView — gemte outfits med billeder
  - Tab 4: TryOnView — virtual try-on flow (foto→vaelg toej→AI→resultat)
- **Components:** GarmentCard, CategoryFilterBar, CameraView, Color+hex
- **Services:** TryOnAPIService (HF Spaces Gradio + Gemini API)
- `.gitignore` for Xcode/Swift
- Assets.xcassets med AccentColor
