# AI Virtual Try-On Research

Researched 2026-03-03. Overblik over de bedste open source AI-modeller, Apple frameworks og gratis API'er til virtual try-on i Frida-appen.

---

## Open Source AI Modeller

### CatVTON (ICLR 2025) — Anbefalet til Frida
- **Arkitektur:** Enkelt kompakt UNet, konkatenerer toj- og personbilleder side om side i spatial dimension
- **VRAM:** Under 8 GB — kan koere paa forbruger-GPU
- **Fordele:** Letvaegtmodel, lav hardware-kraev, nyeste forskning
- **Brug:** Self-hosted backend eller Core ML konvertering
- **GitHub:** https://github.com/Zheng-Chong/CatVTON

### IDM-VTON
- **Arkitektur:** To parallelle UNets med SDXL som fundament
- **GitHub stars:** 4.600+
- **Fordele:** Hoej kvalitet, stor community
- **Ulempe:** Kraever mere GPU (SDXL-baseret)
- **GitHub:** https://github.com/yisol/IDM-VTON

### OOTDiffusion (AAAI 2025)
- **Arkitektur:** To parallelle UNets med Stable Diffusion 1.5 som base
- **GitHub stars:** 6.300+
- **Fordele:** Stoerst community, godt dokumenteret
- **GitHub:** https://github.com/levihsu/OOTDiffusion

### OmniTry
- **Arkitektur:** Baseret paa FLUX.1-Fill-dev med LoRA
- **VRAM:** Minimum 28 GB — kraever professionel GPU
- **Fordele:** Ingen masker noedvendige
- **Ulempe:** Hoeje hardware-krav
- **GitHub:** https://github.com/KwaiVGI/OmniTry

### MV-VTON (AAAI 2025)
- **Arkitektur:** Multi-view — rekonstruerer fra flere vinkler
- **Input:** Front- og bagbilleder af tojet
- **Fordele:** 3D-agtige resultater fra 2D input
- **GitHub:** https://github.com/hywang2002/MV-VTON

### Kolors-VTON
- **Adgang:** Gratis API via Hugging Face Spaces
- **Fordele:** Ingen GPU noedvendig, cloud-baseret
- **Brug:** Direkte API-kald fra appen

---

## Apple Frameworks (on-device, gratis)

### Vision Framework
- 3D body pose detection med op til 19 body points
- Holistic body pose inkl. haender
- On-device, ingen internet kraevet

### ARKit + ARSkeleton3D
- Real-time 3D body tracking i AR
- Live kamera-feed med skeleton overlay
- Brug til live try-on i kameraet

### RealityKit
- 3D rendering med USDZ modeller
- Kan vise 3D-toj paa AR body
- Integration med ARKit

### Core ML
- On-device AI inference
- Konverter PyTorch/ONNX modeller til Core ML format
- Brug til at koere letvaegsmodeller lokalt

### Person Segmentation
- Detekter menneskekroppe i billeder
- Maal individuelle led-positioner i 3D
- Brug til at separere person fra baggrund

---

## Gratis API'er

### Hugging Face Spaces
- **Kolors-VTON** — direkte Gradio API
- **IDM-VTON** — hosted demo med API
- **WeShopAI** — virtual try-on space
- Brug: HTTP POST med billeder, faa resultat tilbage

### Google Gemini API
- Flash experimental model til virtual try-on billeder
- Gratis tier tilgaengelig
- Brug som fallback/alternativ

### Self-hosted CatVTON
- Kraever kun standard GPU (8 GB VRAM)
- Kan hostes paa billig cloud-instans
- Fuld kontrol over data og hastighed

---

## Anbefalet arkitektur for Frida

```
┌─────────────────────────────────────┐
│          Frida iOS App              │
│  SwiftUI + SwiftData + ARKit       │
├─────────────────────────────────────┤
│                                     │
│  On-device (Apple frameworks):      │
│  ├─ Vision: body pose detection     │
│  ├─ Person Segmentation             │
│  ├─ ARKit: live body tracking       │
│  └─ Core ML: lette modeller         │
│                                     │
│  Cloud API (try-on generation):     │
│  ├─ Primaer: CatVTON (self-hosted)  │
│  ├─ Fallback: HF Spaces API        │
│  └─ Alternativ: Gemini API         │
│                                     │
├─────────────────────────────────────┤
│  Flow:                              │
│  1. Bruger tager selfie/vaelger     │
│     foto fra garderobe              │
│  2. Vision/ARKit detekterer krop    │
│  3. Person Segmentation isolerer    │
│  4. Toj-billede sendes med person   │
│     til CatVTON API                 │
│  5. Resultat vises i appen          │
└─────────────────────────────────────┘
```

## Modelsammenligning

| Model | VRAM | Masker | Kvalitet | Hastighed | Anbefalet |
|-------|------|--------|----------|-----------|-----------|
| CatVTON | <8 GB | Ja | Hoej | Hurtig | Ja |
| IDM-VTON | ~16 GB | Ja | Meget hoej | Medium | Fallback |
| OOTDiffusion | ~12 GB | Ja | Hoej | Medium | Alternativ |
| OmniTry | 28+ GB | Nej | Meget hoej | Langsom | Nej (for tung) |
| MV-VTON | ~16 GB | Ja | Hoej (3D) | Langsom | Specialbrug |
| Kolors-VTON | Cloud | Ja | Hoej | Variabel | Gratis API |
