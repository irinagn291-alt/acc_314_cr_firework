import Foundation

/// Linked Art search page. Dedicated decoder, no convertFromSnakeCase.
struct SearchPageDTO: Decodable, Sendable {
    var orderedItems: [EntityRefDTO]
}

struct EntityRefDTO: Decodable, Sendable {
    var id: String
    var type: String?
}

/// Linked Art object. CodingKeys map identified_by, produced_by, representation, member_of, _label.
struct LinkedArtDTO: Decodable, Sendable {
    var id: String?
    var label: String?
    var identifiedBy: [IdentityDTO]?
    var producedBy: ProductionDTO?
    var representation: [RepresentationDTO]?
    var memberOf: [MemberDTO]?

    enum CodingKeys: String, CodingKey {
        case id
        case label = "_label"
        case identifiedBy = "identified_by"
        case producedBy = "produced_by"
        case representation
        case memberOf = "member_of"
    }

    var accession: String? {
        identifiedBy?.first(where: { $0.isAccession })?.content
    }

    var makerLabel: String? {
        producedBy?.makers.first
    }

    var isYaleGallery: Bool {
        memberOf?.contains(where: { $0.isYaleGallery }) ?? false
    }

    func representationPair() -> (full: String, thumb: String)? {
        let digits = representation?.compactMap { $0.digital } ?? []
        let service = digits.compactMap(\.serviceURL).first
        let access = digits.compactMap(\.accessURL).first
        if let service {
            let trimmed = service.hasSuffix("/") ? String(service.dropLast()) : service
            let iiif = "\(trimmed)/full/843,/0/default.jpg"
            return (iiif, access ?? iiif)
        }
        if let access {
            return (access, access)
        }
        return nil
    }
}

struct IdentityDTO: Decodable, Sendable {
    var type: String?
    var content: String?
    var classifiedAs: [LabelDTO]?

    enum CodingKeys: String, CodingKey {
        case type
        case content
        case classifiedAs = "classified_as"
    }

    var isAccession: Bool {
        type == "Identifier" && (classifiedAs?.contains(where: { $0.label?.localizedCaseInsensitiveContains("accession") == true }) ?? false)
    }
}

struct ProductionDTO: Decodable, Sendable {
    var carriedOutBy: [AgentDTO]?
    var part: [ProductionDTO]?

    enum CodingKeys: String, CodingKey {
        case carriedOutBy = "carried_out_by"
        case part
    }

    var makers: [String] {
        let own = carriedOutBy?.compactMap(\.label) ?? []
        let nested = part?.flatMap(\.makers) ?? []
        return own + nested
    }
}

struct AgentDTO: Decodable, Sendable {
    var label: String?

    enum CodingKeys: String, CodingKey {
        case label = "_label"
    }
}

struct MemberDTO: Decodable, Sendable {
    var label: String?

    enum CodingKeys: String, CodingKey {
        case label = "_label"
    }

    var isYaleGallery: Bool {
        label?.localizedCaseInsensitiveContains("Yale University Art Gallery") == true
    }
}

struct RepresentationDTO: Decodable, Sendable {
    var digitallyShownBy: [DigitalObjectDTO]?

    enum CodingKeys: String, CodingKey {
        case digitallyShownBy = "digitally_shown_by"
    }

    var digital: DigitalObjectDTO? { digitallyShownBy?.first }
}

struct DigitalObjectDTO: Decodable, Sendable {
    var accessPoint: [LinkDTO]?
    var service: [LinkDTO]?

    enum CodingKeys: String, CodingKey {
        case accessPoint = "access_point"
        case service
    }

    var accessURL: String? { accessPoint?.first?.id }
    var serviceURL: String? { service?.first?.id }
}

struct LinkDTO: Decodable, Sendable {
    var id: String?
}

struct LabelDTO: Decodable, Sendable {
    var label: String?

    enum CodingKeys: String, CodingKey {
        case label = "_label"
    }
}

enum MakerVoice {
    static func cleaned(_ raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.lowercased().hasPrefix("artist:") {
            text = String(text.dropFirst(7)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let cut = text.firstIndex(of: "(") {
            text = String(text[..<cut]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return text
    }
}
