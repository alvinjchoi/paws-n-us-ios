//
//  Article.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import Foundation

struct Article: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let category: ArticleCategory
    let imageURL: String
    let content: String
    let author: String
    let publishedDate: Date
    let readTime: Int // in minutes
    let location: String? // Seoul, Gyeonggi, Incheon
    
    enum ArticleCategory: String, CaseIterable {
        case guides = "Guides"
        case places = "Places"
        case health = "Health"
        case training = "Training"
        case events = "Events"
        case featured = "Featured"
        
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
}

// Sample data
extension Article {
    static let sampleArticles: [Article] = [
        Article(
            id: "featured1",
            title: "한강공원 반려견 놀이터 완전 정복",
            subtitle: "11개 한강공원별 반려견 전용 공간과 이용 꿀팁을 한눈에 정리했습니다",
            category: .featured,
            imageURL: "https://example.com/hangang-featured.jpg",
            content: """
            서울의 대표적인 휴식 공간인 한강공원에는 반려견과 함께 즐길 수 있는 전용 놀이터가 마련되어 있습니다.
            
            여의도, 뚝섬, 광나루 등 11개 한강공원별로 반려견 놀이터의 특징과 시설, 이용 시간을 상세히 소개합니다.
            
            특히 여의도 한강공원의 경우 대형견과 소형견 구역이 분리되어 있어 안전하게 이용할 수 있으며, 음수대와 그늘막 등 편의시설도 잘 갖춰져 있습니다.
            """,
            author: "김서연",
            publishedDate: Date().addingTimeInterval(-43200),
            readTime: 10,
            location: "서울"
        ),
        Article(
            id: "1",
            title: "성수동 펫 프렌들리 카페 베스트 7",
            subtitle: "강아지와 함께 브런치를 즐길 수 있는 성수동의 인기 카페들",
            category: .places,
            imageURL: "https://example.com/seongsu-cafe.jpg",
            content: """
            최근 성수동에는 반려견 동반이 가능한 세련된 카페들이 많이 생겨나고 있습니다.
            
            단순히 출입만 가능한 것이 아니라, 강아지 전용 메뉴와 놀이 공간까지 마련된 곳들을 엄선했습니다.
            """,
            author: "이민지",
            publishedDate: Date().addingTimeInterval(-86400),
            readTime: 5,
            location: "서울"
        ),
        Article(
            id: "2",
            title: "여름철 강아지 건강 관리법",
            subtitle: "더위에 약한 반려견을 위한 필수 관리 가이드",
            category: .health,
            imageURL: "https://example.com/summer-health.jpg",
            content: """
            무더운 여름, 반려견의 건강을 지키기 위한 필수 관리법을 소개합니다.
            
            열사병 예방법부터 발바닥 화상 방지, 적절한 수분 섭취량까지 수의사가 직접 알려주는 여름철 건강 관리 팁.
            """,
            author: "박수진 수의사",
            publishedDate: Date().addingTimeInterval(-172800),
            readTime: 8,
            location: nil
        ),
        Article(
            id: "3",
            title: "북한산 둘레길 반려견 산책 코스",
            subtitle: "난이도별로 정리한 반려견과 함께 걷기 좋은 둘레길",
            category: .guides,
            imageURL: "https://example.com/bukhansan.jpg",
            content: """
            북한산 둘레길 중에서도 반려견과 함께 걸을 수 있는 구간을 난이도별로 정리했습니다.
            
            초보자도 쉽게 도전할 수 있는 평탄한 코스부터 운동량이 많은 반려견을 위한 중급 코스까지.
            """,
            author: "정현우",
            publishedDate: Date().addingTimeInterval(-259200),
            readTime: 6,
            location: "경기"
        ),
        Article(
            id: "4",
            title: "송도 센트럴파크 반려견 가이드",
            subtitle: "인천의 대표 공원에서 반려견과 즐기는 완벽한 하루",
            category: .places,
            imageURL: "https://example.com/songdo.jpg",
            content: """
            송도 센트럴파크는 반려견과 산책하기 좋은 인천의 대표적인 공간입니다.
            
            호수 주변 산책로, 잔디광장, 그리고 주변의 펫 프렌들리 카페까지 한 번에 즐길 수 있는 코스를 소개합니다.
            """,
            author: "최지은",
            publishedDate: Date().addingTimeInterval(-345600),
            readTime: 7,
            location: "인천"
        ),
        Article(
            id: "5",
            title: "2025 코리아 펫쇼 관람 포인트",
            subtitle: "아시아 최대 반려동물 박람회의 모든 것",
            category: .events,
            imageURL: "https://example.com/petshow.jpg",
            content: """
            오는 8월 코엑스에서 열리는 2025 코리아 펫쇼의 주요 프로그램과 관람 포인트를 미리 살펴봅니다.
            
            신제품 체험존, 무료 건강검진, 행동 교정 상담 등 놓치면 후회할 이벤트들.
            """,
            author: "김태희",
            publishedDate: Date().addingTimeInterval(-432000),
            readTime: 4,
            location: "서울"
        ),
        Article(
            id: "6",
            title: "기초 훈련 완벽 마스터하기",
            subtitle: "앉아, 기다려, 이리와 - 3가지 필수 명령어 훈련법",
            category: .training,
            imageURL: "https://example.com/training.jpg",
            content: """
            반려견과의 안전하고 행복한 생활을 위한 기초 훈련법을 단계별로 알려드립니다.
            
            전문 훈련사가 직접 시연하는 효과적인 훈련 방법과 흔히 하는 실수들.
            """,
            author: "이상훈 훈련사",
            publishedDate: Date().addingTimeInterval(-518400),
            readTime: 12,
            location: nil
        ),
        Article(
            id: "7",
            title: "경기도 애견 펜션 BEST 10",
            subtitle: "반려견과 함께하는 특별한 여행을 위한 펜션 추천",
            category: .places,
            imageURL: "https://example.com/pension.jpg",
            content: """
            가평, 양평, 포천 등 경기도 주요 관광지의 애견 동반 펜션을 엄선했습니다.
            
            전용 운동장, 수영장, 애견 용품 구비 등 시설별 특징과 가격 정보까지.
            """,
            author: "한소영",
            publishedDate: Date().addingTimeInterval(-604800),
            readTime: 9,
            location: "경기"
        ),
        Article(
            id: "featured2",
            title: "우리 동네 24시 동물병원 찾기",
            subtitle: "서울·경기·인천 지역별 야간 진료 가능한 동물병원 완벽 정리",
            category: .featured,
            imageURL: "https://example.com/24h-vet.jpg",
            content: """
            반려견의 응급 상황은 예고 없이 찾아옵니다. 
            
            서울, 경기, 인천 지역의 24시간 운영 또는 야간 진료가 가능한 동물병원을 지역별로 정리했습니다.
            
            각 병원의 진료 시간, 응급 진료 가능 여부, 주요 의료 장비 보유 현황까지 상세히 소개합니다.
            """,
            author: "정수민 수의사",
            publishedDate: Date().addingTimeInterval(-129600),
            readTime: 15,
            location: nil
        ),
        Article(
            id: "featured3",
            title: "강아지와 함께하는 캠핑 입문 가이드",
            subtitle: "초보자를 위한 애견 동반 캠핑의 모든 것",
            category: .featured,
            imageURL: "https://example.com/camping.jpg",
            content: """
            최근 반려견과 함께하는 캠핑이 인기를 끌고 있습니다.
            
            애견 동반 가능한 캠핑장 선택법부터 필수 준비물, 안전 수칙, 에티켓까지 초보자가 알아야 할 모든 정보를 담았습니다.
            
            경기도와 강원도의 추천 애견 캠핑장 리스트도 함께 소개합니다.
            """,
            author: "김현서",
            publishedDate: Date().addingTimeInterval(-216000),
            readTime: 12,
            location: nil
        )
    ]
}