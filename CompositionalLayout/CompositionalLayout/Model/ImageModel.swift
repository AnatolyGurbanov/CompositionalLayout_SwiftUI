//
//  ImageModel.swift
//  CompositionalLayout
//
//  Created by Anatoly Gurbanov on 27.04.2022.
//

import SwiftUI

struct ImageModel: Identifiable, Codable, Hashable {
	var id: String
	var downloadURL: String
	
	enum CodingKeys: String, CodingKey {
		case id
		case downloadURL = "download_url"
	}
}
