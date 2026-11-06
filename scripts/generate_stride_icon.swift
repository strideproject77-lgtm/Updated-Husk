import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let size = 1024
let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                        space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
context.setAllowsAntialiasing(true)
context.setShouldAntialias(true)
func color(_ r: CGFloat,_ g: CGFloat,_ b: CGFloat,_ a: CGFloat = 1)->CGColor { CGColor(red:r,green:g,blue:b,alpha:a) }
func gradient(_ c:[CGColor],_ l:[CGFloat])->CGGradient { CGGradient(colorsSpace:colorSpace,colors:c as CFArray,locations:l)! }
let bg=gradient([color(0.025,0.015,0.075),color(0.09,0.025,0.28),color(0.012,0.008,0.04)],[0,0.5,1])
context.drawLinearGradient(bg,start:CGPoint(x:0,y:0),end:CGPoint(x:size,y:size),options:[])
let glow=gradient([color(0.42,0.08,1,0.68),color(0.32,0.04,0.9,0)],[0,1])
context.drawRadialGradient(glow,startCenter:CGPoint(x:760,y:850),startRadius:10,endCenter:CGPoint(x:760,y:850),endRadius:760,options:[])
let border=CGPath(roundedRect:CGRect(x:48,y:48,width:928,height:928),cornerWidth:185,cornerHeight:185,transform:nil)
context.addPath(border);context.setStrokeColor(color(0.52,0.16,1,0.9));context.setLineWidth(5);context.strokePath()
let s=CGMutablePath()
s.move(to:CGPoint(x:760,y:724))
s.addCurve(to:CGPoint(x:485,y:804),control1:CGPoint(x:680,y:789),control2:CGPoint(x:590,y:804))
s.addCurve(to:CGPoint(x:245,y:609),control1:CGPoint(x:330,y:804),control2:CGPoint(x:245,y:719))
s.addCurve(to:CGPoint(x:485,y:439),control1:CGPoint(x:245,y:504),control2:CGPoint(x:340,y:459))
s.addCurve(to:CGPoint(x:760,y:300),control1:CGPoint(x:605,y:422),control2:CGPoint(x:680,y:300))
context.saveGState();context.addPath(s);context.setLineWidth(112);context.setLineCap(.round);context.setLineJoin(.round);context.replacePathWithStrokedPath();context.clip()
let sg=gradient([color(1,0.99,1),color(0.83,0.75,1),color(0.48,0.18,1)],[0,0.55,1])
context.drawLinearGradient(sg,start:CGPoint(x:260,y:800),end:CGPoint(x:780,y:260),options:[]);context.restoreGState()
context.saveGState();context.translateBy(x:512,y:512);context.rotate(by:-0.49)
context.addPath(CGPath(ellipseIn:CGRect(x:-430,y:-215,width:860,height:430),transform:nil));context.setLineWidth(28);context.replacePathWithStrokedPath();context.clip()
let rg=gradient([color(0.36,0.06,1),color(0.95,0.83,1),color(0.55,0.15,1)],[0,0.48,1])
context.drawLinearGradient(rg,start:CGPoint(x:-430,y:-215),end:CGPoint(x:430,y:215),options:[]);context.restoreGState()
guard let image=context.makeImage() else { fputs("Could not render Stride icon\n",stderr);exit(1) }
let paths=["src/app/Husk/Assets.xcassets/AppIcon.appiconset/Icon-Default.png","src/app/Husk/Assets.xcassets/AppIcon.appiconset/Icon-Dark.png","src/app/Husk/Assets.xcassets/AppIcon.appiconset/Icon-Tinted.png","src/app/Husk/Assets.xcassets/AppIconClearDark.appiconset/Icon-1024.png","src/app/Husk/Assets.xcassets/AppIconClearLight.appiconset/Icon-1024.png","src/app/Husk/Assets.xcassets/AppIconTintedDark.appiconset/Icon-1024.png","src/app/Husk/Assets.xcassets/AppIconTintedLight.appiconset/Icon-1024.png","src/app/Husk/Resources/icon-cleardark.png","src/app/Husk/Resources/icon-clearlight.png","src/app/Husk/Resources/icon-dark.png","src/app/Husk/Resources/icon-default.png","src/app/Husk/Resources/icon-tinteddark.png","src/app/Husk/Resources/icon-tintedlight.png"]
for path in paths {
 let url=root.appendingPathComponent(path)
 try FileManager.default.createDirectory(at:url.deletingLastPathComponent(),withIntermediateDirectories:true)
 guard let dst=CGImageDestinationCreateWithURL(url as CFURL,UTType.png.identifier as CFString,1,nil) else { fputs("Could not create PNG: \(path)\n",stderr);exit(1) }
 CGImageDestinationAddImage(dst,image,nil)
 guard CGImageDestinationFinalize(dst) else { fputs("Could not write PNG: \(path)\n",stderr);exit(1) }
}
print("Generated Stride's 1024x1024 app icon and all appearance previews.")
