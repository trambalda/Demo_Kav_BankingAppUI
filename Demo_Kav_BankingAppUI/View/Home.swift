//
//  Home.swift
//  Demo_Kav_BankingAppUI
//
//  Created by Денис Рубцов on 21.01.2022.
//

import SwiftUI

struct Home: View {
    // MARK: Sample Colors
    @State var colors: [ColorGrid] = [
        ColorGrid(hexValue: "#15654B", color: Color("Green")),
        ColorGrid(hexValue: "#DAA4FF", color: Color("Violet")),
        ColorGrid(hexValue: "#FFD90A", color: Color("Yellow")),
        ColorGrid(hexValue: "#FE9EC4", color: Color("Pink")),
        ColorGrid(hexValue: "#FB3272", color: Color("Orange")),
        ColorGrid(hexValue: "#4460EE", color: Color("Blue")),
    ]
    
    // MARK: Animation Properties
    // Instead of making each boolean for separate animation making it as an array to avoid multiple lines of code
    @State var animations: [Bool] = Array(repeating: false, count: 10)
    
    // MatchedGeometry namespace
    @Namespace var animation
    
    // Card Color
    @State var selectedColor: Color = Color("Pink")
    
    var body: some View {
        
        VStack {
            HStack{
                
                Button {
                    
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .hLeading()

                Button {
                    
                } label: {
                    Image("Profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                }

            }
            .padding([.horizontal, .top])
            .padding(.bottom, 5)
            
            // MARK: Using GeometryReader for Setting Offset
            GeometryReader { proxy in
                // The card will arrive from the top of the screen, in order do that we need to push the card to the top of the screen, simply using GeometryReader to push the view to top
                let maxY = proxy.frame(in: .global).maxY
                CreditCard()
                    // MARK: 3D Rotation
                    .rotation3DEffect(.init(degrees: animations[0] ? 0 : -270), axis: (x: 1, y: 0, z: 0), anchor: .center)
                    .offset(y: animations[0] ? 0 : -maxY)
            }
            .frame(height: 250)
            
            HStack {
                Text("Choose a color")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .hLeading()
                    .offset(x: animations[1] ? 0 : -200)
                Button {
                } label: {
                    Text("View all")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("Pink"))
                        .underline()
                        .offset(x: animations[1] ? 0 : 200)
                }
            }
            .padding()
            
            GeometryReader { _ in
                ZStack {
                    Color.black
                        .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 40))
                        .frame(height: animations[2] ? nil : 0)
                        .vBottom()
                    
                    ZStack {
                        // MARK: Initial grid view
                        ForEach(colors) { colorGrid in
                            // Hiding the source onces
                            if !colorGrid.removeFromView {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(colorGrid.color)
                                    .frame(width: 150, height: animations[3] ? 60 : 150)
                                    .matchedGeometryEffect(id: colorGrid.id, in: animation)
                                    // MARK: Rotating cards
                                    .rotationEffect(.init(degrees: colorGrid.rotateCards ? 180 : 0))
                            }
                        }
                    }
                    // MARK: Applying opacity with scale animation
                    // To avoid this creating a BG averlay and hiding it, so that it will look like the whole stack is applying opacity animation
                    .overlay() {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("BG"))
                            .frame(width: 150, height: animations[3] ? 60 : 150)
                            .opacity(animations[3] ? 0 : 1)
                    }
                    // Scale effect
                    .scaleEffect(animations[3] ? 1 : 2.3)
                }
                .hCenter()
                .vCenter()
                
                // MARK: ScrollView with color grids
                ScrollView(.vertical, showsIndicators: false) {
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(colors) { colorGrid in
                            GridCardView(colorGrid: colorGrid)
                        }
                    }
                    .padding(.top, 40)
                }
                .cornerRadius(40)
            }
            .padding(.top)
        }
        .vTop()
        .hCenter()
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Color("BG"))
        .preferredColorScheme(.dark)
        .onAppear(perform: animateScreen)
    }
    
    // MARK: Grid Card View
    @ViewBuilder
    func GridCardView(colorGrid: ColorGrid) -> some View {
        VStack {
            if colorGrid.addToGrid {
                // Displaying with matched geometry effect
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorGrid.color)
                    .frame(width: 150, height: 60)
                    .matchedGeometryEffect(id: colorGrid.id, in: animation)
                    // When animated grid card is displayed displayng the color text
                    .onAppear {
                        if let index = colors.firstIndex(where: { color in
                            return color.id == colorGrid.id
                        }) {
                            withAnimation {
                                colors[index].showText = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                                withAnimation {
                                    colors[index].removeFromView = true
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            selectedColor = colorGrid.color
                        }
                    }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.clear)
                    .frame(width: 150, height: 60)
            }
            
            Text(colorGrid.hexValue)
                .font(.caption)
                .fontWeight(.light)
                .foregroundColor(.white)
                .hLeading()
                .padding([.horizontal, .top])
                .opacity(colorGrid.showText ? 1 : 0)
        }
    }
    
    
    func animateScreen() {
        // MARK: Animating Screen
        
        // First animation of credit card
        // Delaying first animation after the secon animation
        withAnimation(.interactiveSpring(response: 1.3, dampingFraction: 0.7, blendDuration: 0.7).delay(0.3)) {
            animations[0] = true
        }
        
        // Second Animating the HStack with View All Button
        withAnimation(.easeInOut(duration: 0.7)) {
            animations[1] = true
        }
        
        // Third animation making the bottom to slide up eventually
        withAnimation(.interactiveSpring(response: 1.3, dampingFraction: 0.7, blendDuration: 0.7).delay(0.3)) {
            animations[2] = true
        }
        
        // Fourth animation applying opacity with scale animation for stack grid colors
        withAnimation(.easeInOut(duration: 0.8)) {
            animations[3] = true
        }
        
        // Final grid forming animation
        for index in colors.indices {
            // Animation after the opacity animation has finished its job
            // Rotating one card another with a time delay os 0.1 sec
            let delay: Double = (0.9 + Double(index) * 0.1)
            
            // Last card is rotating first since we're putting in ZStack to avoid this recalculate index from back
            let backIndex = (colors.count - 1) - index
            
            withAnimation(.easeInOut.delay(delay)) {
                colors[backIndex].rotateCards = true
            }
            
            // After rotation adding it to grid view one after another. Since .delay() will not work with if..else so using DispatchQueue delay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation {
                    colors[backIndex].addToGrid = true
                }
            }
        }
    }
    
    // MARK: Animated Credit Card
    @ViewBuilder
    func CreditCard() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(selectedColor)
            VStack {
                HStack {
                    ForEach(1 ... 4, id: \.self) { _ in
                        Circle()
                            .fill(.white)
                            .frame(width: 6, height: 6)
                    }
                    Text("7864")
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                .hLeading()
                
                HStack(spacing: -12) {
                    Text("Hanna Adler")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .hLeading()
                    Circle()
                        .stroke(.white, lineWidth: 1)
                        .frame(width: 30, height: 30)
                    Circle()
                        .stroke(.white, lineWidth: 1)
                        .frame(width: 30, height: 30)
                }
                .vBottom()
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
            .vTop()
            .hLeading()
            
            // MARK: Top Ring
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 18)
                .offset(x: 130, y: -120)
        }
        .clipped()
        .padding()
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

// MARK: Extensions for Making UI Desigh Faster
extension View {
    
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    func hTrailing() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

    func hCenter() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
    }

    func vCenter() -> some View {
        self
            .frame(maxHeight: .infinity, alignment: .center)
    }

    func vTop() -> some View {
        self
            .frame(maxHeight: .infinity, alignment: .top)
    }

    func vBottom() -> some View {
        self
            .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
