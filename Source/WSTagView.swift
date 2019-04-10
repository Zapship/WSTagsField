//
//  WSTagView.swift
//  Whitesmith
//
//  Created by Ricardo Pereira on 12/05/16.
//  Copyright © 2016 Whitesmith. All rights reserved.
//

import UIKit
import ContextMenu

protocol Tapable: class {}
extension Tapable {
    func tap(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Tapable {}

open class WSTagView: UIView {
    fileprivate let textLabel = UILabel()
    private var _tag: WSTag? {
        didSet {
            self.displayText = _tag?.text ?? ""
            updateLabelText()
        }
    }
    let arrow = UIButton(frame: .zero).tap {
        let bundle = Bundle(for: WSTagView.self)
        let dropdown = UIImage(named: "down-arrow", in: bundle, compatibleWith: nil)!
        $0.setImage(dropdown, for: .normal)
    }

    open var displayText: String = "" {
        didSet {
            updateLabelText()
            setNeedsDisplay()
        }
    }

    open var displayDelimiter: String = "" {
        didSet {
            updateLabelText()
            setNeedsDisplay()
        }
    }

    open var font: UIFont? {
        didSet {
            textLabel.font = font
            setNeedsDisplay()
        }
    }

    open override var tintColor: UIColor! {
        didSet { updateContent(animated: false) }
    }

    @objc open var cornerRadius: CGFloat = 1.0 {
        didSet {
            updateContent(animated: false)
        }
    }

    /// Background color to be used for selected state.
    open var selectedColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    open var textColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    open var selectedTextColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    open var keyboardAppearanceType: UIKeyboardAppearance = .default

    internal var onDidRequestDelete: ((_ tagView: WSTagView, _ replacementText: String?) -> Void)?
    internal var onDidRequestSelection: ((_ tagView: WSTagView) -> Void)?
    internal var onDidInputText: ((_ tagView: WSTagView, _ text: String) -> Void)?

    public var onDidSelectOtherOption: ((_ tagView: WSTagView, _ oldTag: WSTag, _ newTag: WSTag) -> Void)?

    open var selected: Bool = false {
        didSet {
            if selected && !isFirstResponder {
                _ = becomeFirstResponder()
            } else
                if !selected && isFirstResponder {
                    _ = resignFirstResponder()
            }
            updateContent(animated: true)
        }
    }

    public init(tag: WSTag) {
        self._tag = tag
        super.init(frame: CGRect.zero)
        self.backgroundColor = tintColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 233/255.0, green: 234/255.0, blue: 240/255.0, alpha: 1.0).cgColor
        textColor = .white
        selectedColor = .gray
        selectedTextColor = .black

        textLabel.frame = CGRect(x: layoutMargins.left, y: layoutMargins.top, width: 0, height: 0)
        textLabel.font = font
        textLabel.textColor = .white
        textLabel.backgroundColor = .clear
        addSubview(textLabel)
        if !tag.otherOptions.isEmpty {
            addSubview(arrow)
            arrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMoreOptions)))
        }

        self.displayText = tag.text
        updateLabelText()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        let longPresssRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTapMoreOptions))
        addGestureRecognizer(tapRecognizer)
        addGestureRecognizer(longPresssRecognizer)
        setNeedsLayout()
    }

    public required init?(coder aDecoder: NSCoder) {
        self._tag = nil
        super.init(coder: aDecoder)
        assert(false, "Not implemented")
    }

    fileprivate func updateColors() {
        self.backgroundColor = selected ? selectedColor : tintColor
        textLabel.textColor = selected ? selectedTextColor : textColor
    }

    internal func updateContent(animated: Bool) {
        guard animated else {
            updateColors()
            return
        }

        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.updateColors()
                if self?.selected ?? false {
                    self?.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                }
            },
            completion: { [weak self] _ in
                if self?.selected ?? false {
                    UIView.animate(withDuration: 0.4) { [weak self] in
                        self?.transform = CGAffineTransform.identity
                    }
                }
            }
        )
    }

    // MARK: - Size Measurements
    open override var intrinsicContentSize: CGSize {
        let labelIntrinsicSize = textLabel.intrinsicContentSize
        return CGSize(width: labelIntrinsicSize.width + layoutMargins.left + layoutMargins.right + (self._tag?.otherOptions.isEmpty ?? true ? 0 : 15),
                      height: labelIntrinsicSize.height + layoutMargins.top + layoutMargins.bottom)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layoutMarginsHorizontal = layoutMargins.left + layoutMargins.right
        let layoutMarginsVertical = layoutMargins.top + layoutMargins.bottom
        let fittingSize = CGSize(width: size.width - layoutMarginsHorizontal,
                                 height: size.height - layoutMarginsVertical)
        let labelSize = textLabel.sizeThatFits(fittingSize)
        return CGSize(width: labelSize.width + layoutMarginsHorizontal,
                      height: labelSize.height + layoutMarginsVertical)
    }

    open func sizeToFit(_ size: CGSize) -> CGSize {
        if intrinsicContentSize.width > size.width {
            return CGSize(width: size.width,
                          height: intrinsicContentSize.height)
        }
        return intrinsicContentSize
    }

    // MARK: - Attributed Text
    fileprivate func updateLabelText() {
        // Unselected shows "[displayText]," and selected is "[displayText]"
        textLabel.text = displayText + displayDelimiter
        // Expand Label
        let intrinsicSize = self.intrinsicContentSize
        frame = CGRect(x: 0, y: 0, width: intrinsicSize.width, height: intrinsicSize.height)
    }

    // MARK: - Laying out
    open override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = bounds.inset(by: layoutMargins)
        arrow.frame = CGRect(x: textLabel.frame.origin.x + textLabel.intrinsicContentSize.width + 5.0, y: frame.size.height/2 - 5, width: 10, height: 10)
        if frame.width == 0 || frame.height == 0 {
            frame.size = self.intrinsicContentSize
        }
    }

    // MARK: - First Responder (needed to capture keyboard)
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        selected = true
        return didBecomeFirstResponder
    }

    open override func resignFirstResponder() -> Bool {
        let didResignFirstResponder = super.resignFirstResponder()
        selected = false
        return didResignFirstResponder
    }

    // MARK: - Gesture Recognizers
    @objc func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        if selected {
            handleTapGestureRecognizer(sender)
            return
        }
        onDidRequestSelection?(self)
    }

    @objc func handleTapMoreOptions(_ sender: UITapGestureRecognizer) {
        if !selected {
            _ = becomeFirstResponder()
        }
        guard let parentViewcontroller = parentViewController else { return }
        let emailSelector = ItemSelectorViewController<String>()
        emailSelector.delegate = self
        emailSelector.items = self._tag?.otherOptions ?? []
        ContextMenu.shared.show(
            sourceViewController: parentViewcontroller,
            viewController: emailSelector,
            options: ContextMenu.Options(menuStyle: .minimal),
            sourceView: sender.view)
    }

    private var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension WSTagView: UIKeyInput {

    public var hasText: Bool {
        return true
    }

    public func insertText(_ text: String) {
        onDidInputText?(self, text)
    }

    public func deleteBackward() {
        onDidRequestDelete?(self, nil)
    }

}

extension WSTagView: UITextInputTraits {

    // Solves an issue where autocorrect suggestions were being
    // offered when a tag is highlighted.
    public var autocorrectionType: UITextAutocorrectionType {
        get { return .no }
        set { }
    }

    public var keyboardAppearance: UIKeyboardAppearance {
        get { return keyboardAppearanceType }
        set { }
    }

}

extension WSTagView: ItemSelectorDelegate {
    func didSelectOtherOption(tag: String) {
        self.parentViewController?.dismiss(animated: true, completion: nil)
        guard let oldTag = self._tag else { return }
        self._tag = WSTag(
            id: oldTag.id,
            text: tag,
            otherOptions: [oldTag.text] + oldTag.otherOptions.filter { $0 != tag })
        self.onDidSelectOtherOption?(self, oldTag, self._tag!)
    }
}
