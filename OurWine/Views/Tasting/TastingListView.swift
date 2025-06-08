//
//  TastingListView.swift
//  OurWine
//
//  Created by Marcos Riosalido Vilagrasa on 9/6/25.
//

import SwiftUI
import SwiftData

struct TastingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tasting.createdAt, order: .reverse) private var tastings: [Tasting]
    
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                content
                fab
            }
            .navigationTitle("Catas")
            .sheet(isPresented: $showingAddSheet) {
                AddTastingView()
            }
        }
    }
    
    // MARK: - Vistas Descompuestas
    
    @ViewBuilder
    private var content: some View {
        if tastings.isEmpty {
            emptyView
        } else {
            tastingList
        }
    }
    
    private var fab: some View {
        Button(action: { showingAddSheet = true }) {
            Image(systemName: "plus")
                .font(.title.weight(.semibold))
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 5, x: 0, y: 5)
        }
        .padding()
    }
    
    private var emptyView: some View {
        Text("No tienes ninguna cata registrada.\n¡Añade la primera!")
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var tastingList: some View {
        List(tastings) { tasting in
            VStack(alignment: .leading) {
                Text("Cata del \(tasting.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.headline)
                
                if let wineName = tasting.wine?.name {
                    Text("Vino: \(wineName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

