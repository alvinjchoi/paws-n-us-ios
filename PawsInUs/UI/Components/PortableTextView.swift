//
//  PortableTextView.swift
//  Pawsinus
//
//  Created by Assistant on 1/28/25.
//

import SwiftUI

struct PortableTextView: View {
    let block: PortableTextBlock
    
    var body: some View {
        Group {
            switch block._type {
            case "block":
                blockView
            default:
                Text("Unsupported block type: \(block._type)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var blockView: some View {
        if let children = block.children, !children.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                let spans = children.map { span in
                    createAttributedText(from: span)
                }
                
                Text(spans.reduce(AttributedString()) { result, span in
                    result + span
                })
                .font(fontForStyle(block.style))
                .lineSpacing(4)
            }
        } else {
            Text(block.toPlainText())
                .font(fontForStyle(block.style))
                .lineSpacing(4)
        }
    }
    
    private func createAttributedText(from span: PortableTextSpan) -> AttributedString {
        var attributedString = AttributedString(span.text)
        
        if let marks = span.marks {
            for mark in marks {
                switch mark {
                case "strong":
                    attributedString.font = .body.bold()
                case "em":
                    attributedString.font = .body.italic()
                case "underline":
                    attributedString.underlineStyle = .single
                default:
                    break
                }
            }
        }
        
        return attributedString
    }
    
    private func fontForStyle(_ style: String?) -> Font {
        guard let style = style else { return .body }
        
        switch style {
        case "h1":
            return .largeTitle
        case "h2":
            return .title
        case "h3":
            return .title2
        case "h4":
            return .title3
        case "h5":
            return .headline
        case "h6":
            return .subheadline
        case "blockquote":
            return .body.italic()
        default:
            return .body
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        PortableTextView(block: PortableTextBlock(
            _type: "block",
            _key: "test",
            style: "normal",
            children: [
                PortableTextSpan(_type: "span", _key: "span1", text: "This is ", marks: nil),
                PortableTextSpan(_type: "span", _key: "span2", text: "bold text", marks: ["strong"]),
                PortableTextSpan(_type: "span", _key: "span3", text: " and this is ", marks: nil),
                PortableTextSpan(_type: "span", _key: "span4", text: "italic text", marks: ["em"]),
                PortableTextSpan(_type: "span", _key: "span5", text: ".", marks: nil)
            ],
            markDefs: nil
        ))
        
        PortableTextView(block: PortableTextBlock(
            _type: "block",
            _key: "test2",
            style: "h2",
            children: [
                PortableTextSpan(_type: "span", _key: "span6", text: "This is a heading", marks: nil)
            ],
            markDefs: nil
        ))
    }
    .padding()
}