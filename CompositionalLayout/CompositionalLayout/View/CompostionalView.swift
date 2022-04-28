//
//  CompostionalView.swift
//  CompositionalLayout
//
//  Created by Anatoly Gurbanov on 26.04.2022.
//

import SwiftUI

fileprivate enum LayoutType {
	case firstType
	case secondType
	case thirdType
}

struct CompostionalView<Content, Item, ID>:
	View where Content: View,
			   ID: Hashable,
			   Item: RandomAccessCollection,
			   Item.Element: Hashable {

	var content: (Item.Element) -> Content
	var items: Item
	var id: KeyPath<Item.Element, ID>
	var spacing: CGFloat
	
	init(
		items: Item,
		id: KeyPath<Item.Element, ID>,
		spacing: CGFloat = 5,
		@ViewBuilder content: @escaping (Item.Element) -> Content
	) {
		self.content = content
		self.id = id
		self.items = items
		self.spacing = spacing
	}

	var body: some View {
		LazyVStack(spacing: spacing) {
			ForEach(generateColumns(), id: \.self) { row in
				rowView(row: row)
			}
		}
	}
	
	// MARK: Identifying Row Type
	private func layoutType(row: [Item.Element]) -> LayoutType {
		let index = generateColumns().firstIndex { item in
			return item == row
		} ?? 0
		
		var types: [LayoutType] = []
		generateColumns().forEach() { _ in
			if types.isEmpty {
				types.append(.firstType)
			} else if types.last == .firstType {
				types.append(.secondType)
			} else if types.last == . secondType {
				types.append(.thirdType)
			} else if types.last == .thirdType {
				types.append(.firstType)
			}
		}
		
		return types[index]
	}
	
	// MARK: - Row View

	@ViewBuilder
	private func rowView(row: [Item.Element]) -> some View {
		GeometryReader { proxy in
			let width = proxy.size.width
			let height = (proxy.size.height - spacing) / 2
			let type = layoutType(row: row)
			let columnWidth = (width > 0 ? ((width - (spacing * 2)) / 3) : 0)
			
			HStack(spacing: spacing) {
				if type == .firstType {
					safeView(row: row, index: 0)
					VStack(spacing: spacing) {
						safeView(row: row, index: 1)
							.frame(height: height)
						safeView(row: row, index: 2)
							.frame(height: height)
					}
					.frame(width: columnWidth)
				}
				
				if type == .secondType {
					HStack(spacing: spacing) {
						safeView(row: row, index: 2)
							.frame(width: columnWidth)
						safeView(row: row, index: 1)
							.frame(width: columnWidth)
						safeView(row: row, index: 0)
							.frame(width: columnWidth)
					}
				}

				if type == .thirdType {
					VStack(spacing: spacing) {
						safeView(row: row, index: 0)
							.frame(height: height)
						safeView(row: row, index: 1)
							.frame(height: height)
					}
					.frame(width: columnWidth)
					safeView(row: row, index: 2)
				}
			}
		}
		.frame(
			height:
			layoutType(row: row) == .firstType ||
			layoutType(row: row) == .thirdType ?
			250 :
			120
		)
	}
	
	/// Safely unwrapping content index
	@ViewBuilder
	private func safeView(row: [Item.Element], index: Int) -> some View {
		if (row.count - 1) >= index {
			content(row[index])
		}
	}
	
	/// Constructing custom rows and columns
	private func generateColumns() -> [[Item.Element]] {
		var columns: [[Item.Element]] = []
		var rows: [Item.Element] = []
		
		for item in items {
			if rows.count == 3 {
				columns.append(rows)
				rows.removeAll()
				rows.append(item)
			} else {
				rows.append(item)
			}
		}
		
		columns.append(rows)
		rows.removeAll()
		return columns
	}
}

struct CompostionalView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
