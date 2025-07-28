//
//  Article.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import Foundation
import UIKit

struct Article: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let category: String
    let imageUrl: String?
    let author: String
    let publishedDate: String
    let readTime: Int
    let location: String?
    let featured: Bool
    let slug: String
    let content: [PortableTextBlock]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, subtitle, category, imageUrl, author, publishedDate, readTime, location, featured, slug, content
    }
    
    // Computed properties for UI
    var parsedDate: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: publishedDate) ?? Date()
    }
    
    var categoryEnum: ArticleCategory {
        return ArticleCategory(rawValue: category) ?? .guides
    }
    
    // Static equality for Equatable (ignoring content blocks for performance)
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.subtitle == rhs.subtitle &&
               lhs.category == rhs.category
    }
}

// MARK: - Article Categories
enum ArticleCategory: String, CaseIterable, Codable {
    case guides = "guides"
    case places = "places"
    case health = "health"
    case training = "training"
    case events = "events"
    case featured = "featured"
    
    var displayName: String {
        switch self {
        case .guides: return "가이드"
        case .places: return "장소"
        case .health: return "건강"
        case .training: return "훈련"
        case .events: return "이벤트"
        case .featured: return "추천"
        }
    }
}

// MARK: - Portable Text Models
struct PortableTextBlock: Codable, Identifiable {
    let id = UUID()
    let _type: String
    let _key: String?
    let style: String?
    let children: [PortableTextSpan]?
    let markDefs: [PortableTextMarkDef]?
    
    enum CodingKeys: String, CodingKey {
        case _type, _key, style, children, markDefs
    }
}

struct PortableTextSpan: Codable {
    let _type: String
    let _key: String?
    let text: String
    let marks: [String]?
    
    enum CodingKeys: String, CodingKey {
        case _type, _key, text, marks
    }
}

struct PortableTextMarkDef: Codable {
    let _type: String
    let _key: String
    let href: String?
    
    enum CodingKeys: String, CodingKey {
        case _type, _key, href
    }
}

// MARK: - Portable Text Renderer
extension PortableTextBlock {
    func toPlainText() -> String {
        guard let children = children else { return "" }
        return children.map { $0.text }.joined()
    }
    
    func toAttributedString() -> NSAttributedString {
        guard let children = children else { 
            return NSAttributedString(string: "")
        }
        
        let result = NSMutableAttributedString()
        
        for child in children {
            let text = child.text
            let attributedText = NSMutableAttributedString(string: text)
            
            // Apply basic styling based on marks
            if let marks = child.marks {
                for mark in marks {
                    switch mark {
                    case "strong":
                        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: text.count))
                    case "em":
                        attributedText.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: 16), range: NSRange(location: 0, length: text.count))
                    default:
                        break
                    }
                }
            }
            
            result.append(attributedText)
        }
        
        return result
    }
}

// Sample data
extension Article {
    static let sampleArticles: [Article] = [
        Article(
            id: "featured1",
            title: "한강공원 반려견 놀이터 완전 정복",
            subtitle: "11개 한강공원별 반려견 전용 공간과 이용 꿀팁을 한눈에 정리했습니다",
            category: ArticleCategory.featured.rawValue,
            imageUrl: "https://example.com/hangang-featured.jpg",
            author: "김서연",
            publishedDate: Date().addingTimeInterval(-43200).ISO8601Format(),
            readTime: 10,
            location: "서울",
            featured: true,
            slug: "hangang-dog-playground-guide",
            content: [
                PortableTextBlock(
                    _type: "block",
                    _key: "block1",
                    style: "normal",
                    children: [
                        PortableTextSpan(_type: "span", _key: "span1", text: "서울의 대표적인 휴식 공간인 한강공원에는 반려견과 함께 즐길 수 있는 전용 놀이터가 마련되어 있습니다.", marks: nil)
                    ],
                    markDefs: nil
                ),
                PortableTextBlock(
                    _type: "block",
                    _key: "block2",
                    style: "normal",
                    children: [
                        PortableTextSpan(_type: "span", _key: "span2", text: "여의도, 뚝섬, 광나루 등 11개 한강공원별로 반려견 놀이터의 특징과 시설, 이용 시간을 상세히 소개합니다.", marks: nil)
                    ],
                    markDefs: nil
                ),
                PortableTextBlock(
                    _type: "block",
                    _key: "block3",
                    style: "normal",
                    children: [
                        PortableTextSpan(_type: "span", _key: "span3", text: "특히 여의도 한강공원의 경우 대형견과 소형견 구역이 분리되어 있어 안전하게 이용할 수 있으며, 음수대와 그늘막 등 편의시설도 잘 갖춰져 있습니다.", marks: nil)
                    ],
                    markDefs: nil
                )
            ]
        ),
        Article(
            id: "1",
            title: "성수동 펫 프렌들리 카페 베스트 7",
            subtitle: "강아지와 함께 브런치를 즐길 수 있는 성수동의 인기 카페들",
            category: ArticleCategory.places.rawValue,
            imageUrl: "https://example.com/seongsu-cafe.jpg",
            author: "이민지",
            publishedDate: Date().addingTimeInterval(-86400).ISO8601Format(),
            readTime: 5,
            location: "서울",
            featured: false,
            slug: "seongsu-pet-cafe-best-7",
            content: nil
        ),
        Article(
            id: "2",
            title: "여름철 강아지 건강 관리법",
            subtitle: "더위에 약한 반려견을 위한 필수 관리 가이드",
            category: ArticleCategory.health.rawValue,
            imageUrl: "https://example.com/summer-health.jpg",
            author: "박수진 수의사",
            publishedDate: Date().addingTimeInterval(-172800).ISO8601Format(),
            readTime: 8,
            location: nil,
            featured: false,
            slug: "summer-dog-health-guide",
            content: nil
        ),
        Article(
            id: "3",
            title: "북한산 둘레길 반려견 산책 코스",
            subtitle: "난이도별로 정리한 반려견과 함께 걷기 좋은 둘레길",
            category: ArticleCategory.guides.rawValue,
            imageUrl: "https://example.com/bukhansan.jpg",
            author: "정현우",
            publishedDate: Date().addingTimeInterval(-259200).ISO8601Format(),
            readTime: 6,
            location: "경기",
            featured: false,
            slug: "bukhansan-dog-trail-guide",
            content: nil
        ),
        Article(
            id: "4",
            title: "송도 센트럴파크 반려견 가이드",
            subtitle: "인천의 대표 공원에서 반려견과 즐기는 완벽한 하루",
            category: ArticleCategory.places.rawValue,
            imageUrl: "https://example.com/songdo.jpg",
            author: "최지은",
            publishedDate: Date().addingTimeInterval(-345600).ISO8601Format(),
            readTime: 7,
            location: "인천",
            featured: false,
            slug: "songdo-central-park-dog-guide",
            content: nil
        ),
        Article(
            id: "5",
            title: "2025 코리아 펫쇼 관람 포인트",
            subtitle: "아시아 최대 반려동물 박람회의 모든 것",
            category: ArticleCategory.events.rawValue,
            imageUrl: "https://example.com/petshow.jpg",
            author: "김태희",
            publishedDate: Date().addingTimeInterval(-432000).ISO8601Format(),
            readTime: 4,
            location: "서울",
            featured: false,
            slug: "2025-korea-pet-show-guide",
            content: nil
        ),
        Article(
            id: "6",
            title: "기초 훈련 완벽 마스터하기",
            subtitle: "앉아, 기다려, 이리와 - 3가지 필수 명령어 훈련법",
            category: ArticleCategory.training.rawValue,
            imageUrl: "https://example.com/training.jpg",
            author: "이상훈 훈련사",
            publishedDate: Date().addingTimeInterval(-518400).ISO8601Format(),
            readTime: 12,
            location: nil,
            featured: false,
            slug: "basic-dog-training-guide",
            content: nil
        ),
        Article(
            id: "7",
            title: "경기도 애견 펜션 BEST 10",
            subtitle: "반려견과 함께하는 특별한 여행을 위한 펜션 추천",
            category: ArticleCategory.places.rawValue,
            imageUrl: "https://example.com/pension.jpg",
            author: "한소영",
            publishedDate: Date().addingTimeInterval(-604800).ISO8601Format(),
            readTime: 9,
            location: "경기",
            featured: false,
            slug: "gyeonggi-dog-pension-best-10",
            content: nil
        ),
        Article(
            id: "featured2",
            title: "우리 동네 24시 동물병원 찾기",
            subtitle: "서울·경기·인천 지역별 야간 진료 가능한 동물병원 완벽 정리",
            category: ArticleCategory.featured.rawValue,
            imageUrl: "https://example.com/24h-vet.jpg",
            author: "정수민 수의사",
            publishedDate: Date().addingTimeInterval(-129600).ISO8601Format(),
            readTime: 15,
            location: nil,
            featured: true,
            slug: "24h-animal-hospital-guide",
            content: nil
        ),
        Article(
            id: "featured3",
            title: "강아지와 함께하는 캠핑 입문 가이드",
            subtitle: "초보자를 위한 애견 동반 캠핑의 모든 것",
            category: ArticleCategory.featured.rawValue,
            imageUrl: "https://example.com/camping.jpg",
            author: "김현서",
            publishedDate: Date().addingTimeInterval(-216000).ISO8601Format(),
            readTime: 12,
            location: nil,
            featured: true,
            slug: "dog-camping-beginner-guide",
            content: nil
        )
    ]
}