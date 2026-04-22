// MapFogOfWar — fog-of-war rendering via inverted MultiPolygon (SCRUM-27)
//
// Public API:
//   VisitedCells         — protocol for providing visited hex cells
//   FogLayer             — MapContent for composing fog into a MapView
//   FogStyle             — visual styling for the fog overlay
//   FogResolutionPolicy  — zoom → HexResolution mapping utility
//   FogGeoJSONBuilder    — inverted MultiPolygon GeoJSON construction
//   FogUpdateThrottle    — rate limiter for GeoJSON source updates
