//
//  Calculator - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mainOperandLabel: UILabel!
    @IBOutlet weak var mainOperatorLabel: UILabel!
    @IBOutlet weak var formulaHistoryView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    var operandLabelText: String = ""
    var partialFormula: String = ""
    var formula: Formula = ExpressionParser.parse(from: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        operandLabelText = mainOperandLabel.text ?? ""
        mainOperandLabel.text = operandLabelText.applyNumberFormatterAtMainLabel()
    }
    
    //MARK: - NumberPad 메서드
    @IBAction func touchUpNumberButton(_ sender: UIButton) {
        operandLabelText += sender.tag.description
        mainOperandLabel.text = operandLabelText.applyNumberFormatterAtMainLabel()
    }
    
    @IBAction func touchUpZeroButton(_ sender: UIButton) {
        guard Double(operandLabelText) != 0 else { return }
        
        operandLabelText += sender.currentTitle ?? ""
        mainOperandLabel.text = operandLabelText.applyNumberFormatterAtMainLabel()
    }
    
    @IBAction func touchUpDotButton(_ sender: UIButton) {
        guard !operandLabelText.contains(".") else { return }
        
        operandLabelText += "."
        mainOperandLabel.text = operandLabelText.applyNumberFormatterAtMainLabel() + "."
    }
    
    //MARK: - 사칙연산 메서드
    @IBAction func touchUpFormulaButton(_ sender: UIButton) {
        if formula.operands.isEmpty, mainOperandLabel.text == "0" {
            return
        } else if mainOperandLabel.text == "0" {
            mainOperatorLabel.text = sender.currentTitle ?? ""
        } else {
            updateFormulaType()
            addStackViewInFormulaHistoryView()
            resetMainFormulaView(sender)
            scrollToBottom()
        }
    }
    
    func updateFormulaType() {
        let operatorValue: String = mainOperatorLabel.rawValueByOperatorLabelText
        let operandValue: String = operandLabelText
        
        partialFormula += operatorValue + " " + operandValue + " "
        formula = ExpressionParser.parse(from: partialFormula)
    }
    
    func addStackViewInFormulaHistoryView() {
        let stackView: UIStackView = UIStackView()
        stackView.spacing = 8
        
        let operandLabel: UILabel = UILabel()
        operandLabel.text = mainOperandLabel.text?.applyNumberFormatterAtFormulaHistoryView()
        
        let operatorLabel: UILabel = UILabel()
        operatorLabel.text = mainOperatorLabel.text
        
        [operatorLabel, operandLabel].forEach {
            $0.textColor = .white
            $0.font = UIFont.preferredFont(forTextStyle: .title3)
            stackView.addArrangedSubview($0)
        }
        
        formulaHistoryView.addArrangedSubview(stackView)
    }
    
    func scrollToBottom() {
        scrollView.setContentOffset(
            CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height),
            animated: false)
    }
    
    func resetMainFormulaView(_ sender: UIButton) {
        operandLabelText = ""
        mainOperandLabel.text = "0"
        mainOperatorLabel.text = sender.currentTitle ?? ""
    }
    
    @IBAction func touchUpEqualButton(_ sender: UIButton) {
        guard let result =
                try? formula.result().description.applyNumberFormatterAtFormulaHistoryView(),
              result !=
                mainOperandLabel.text?.applyNumberFormatterAtFormulaHistoryView() else { return }
        
        updateFormulaType()
        addStackViewInFormulaHistoryView()
        showFormulaResult()
    }
    
    func showFormulaResult() {
        do {
            mainOperandLabel.text =
            try formula.result().description.applyNumberFormatterAtFormulaHistoryView()
        } catch CalculationError.dividedZero {
            mainOperandLabel.text = "NaN"
        } catch {}
        mainOperatorLabel.text = ""
    }
    
    // MARK: - 기능 메서드
    @IBAction func touchUpCEButton(_ sender: UIButton) {
        operandLabelText = ""
        mainOperandLabel.text = "0"
    }
    
    @IBAction func touchUpACButton(_ sender: UIButton) {
        operandLabelText = ""
        deleteStackViewInScrollView()
        resetMainLabelText()
        resetFormulaType()
    }
    
    func deleteStackViewInScrollView() {
        formulaHistoryView.subviews.forEach {
            $0.isHidden = true
        }
    }
    
    func resetMainLabelText() {
        mainOperatorLabel.text = ""
        mainOperandLabel.text = "0"
    }
    
    func resetFormulaType() {
        partialFormula = ""
        formula.operands.removeAll()
        formula.operators.removeAll()
    }
    
    @IBAction func touchUpSignButton(_ sender: UIButton) {
        guard let operandLabelText = mainOperandLabel.text,
        operandLabelText != "0" else { return }
        
        operandLabelText.contains("-") ?
        (mainOperandLabel.text = operandLabelText.split(with: "-").joined()) :
        (mainOperandLabel.text = "-" + operandLabelText)
    }
}
