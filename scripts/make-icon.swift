// Renders the Finder/DMG app icon from the same SF Symbol the menu bar uses.
// Usage: swift scripts/make-icon.swift <output-dir>
// Produces AppIcon.iconset/*.png; the Makefile turns it into AppIcon.icns.
import AppKit

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "build/AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

func render(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else { return image }
    ctx.setShouldAntialias(true)

    // macOS icon grid: the artwork sits inside ~80% of the canvas.
    let inset = s * 0.10
    let rect = CGRect(x: inset, y: inset, width: s - 2 * inset, height: s - 2 * inset)
    let path = NSBezierPath(roundedRect: rect, xRadius: rect.width * 0.2237, yRadius: rect.width * 0.2237)

    // Soft shadow under the tile.
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -s * 0.012), blur: s * 0.03,
                  color: NSColor.black.withAlphaComponent(0.35).cgColor)
    NSColor(calibratedRed: 0.36, green: 0.22, blue: 0.14, alpha: 1).setFill()
    path.fill()
    ctx.restoreGState()

    // Warm coffee gradient.
    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.47, green: 0.30, blue: 0.19, alpha: 1),
        NSColor(calibratedRed: 0.30, green: 0.17, blue: 0.10, alpha: 1),
    ])!
    gradient.draw(in: path, angle: -90)

    // The cup, in cream.
    let config = NSImage.SymbolConfiguration(pointSize: s * 0.44, weight: .medium)
        .applying(.init(paletteColors: [NSColor(calibratedRed: 0.98, green: 0.94, blue: 0.86, alpha: 1)]))
    if let symbol = NSImage(systemSymbolName: "cup.and.heat.waves.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(config) {
        let symSize = symbol.size
        let origin = CGPoint(x: (s - symSize.width) / 2, y: (s - symSize.height) / 2 - s * 0.01)
        symbol.draw(in: CGRect(origin: origin, size: symSize))
    }
    image.unlockFocus()
    return image
}

func write(_ image: NSImage, pixels: Int, name: String) {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: pixels, height: pixels)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: pixels, height: pixels))
    NSGraphicsContext.restoreGraphicsState()
    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: "\(outDir)/\(name)"))
}

for base in [16, 32, 128, 256, 512] {
    write(render(size: base), pixels: base, name: "icon_\(base)x\(base).png")
    write(render(size: base * 2), pixels: base * 2, name: "icon_\(base)x\(base)@2x.png")
}
print("wrote iconset to \(outDir)")
