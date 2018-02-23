//
//  Matrix.swift
//  Logic
//
//  Created by KimYusung on 2017/12/02.
//  Copyright © 2017 yusungkim. All rights reserved.
//

import Foundation

enum Cell: Int, CustomStringConvertible {
    case marked
    case blank
    case unknown
    var description: String {
        switch self {
        case .unknown:
            return "😅"
        case .marked:
            return "⬛️"
        case .blank:
            return "⬜️"
        }
    }
    var toggle: Cell {
        return Cell(rawValue: rawValue + 1) ?? .marked
    }
}

enum FinishedMarking {
    case finished
    case notFinished
}

struct Matrix: CustomStringConvertible {
    private var matrix = [Array<Cell>]()
    private var _hintsForRows = [Array<Int>]()
    private var _hintsForColumns = [Array<Int>]()
    private var isFinishedMarkingWithRowHints = Array<FinishedMarking>()
    private var isFinishedMarkingWithColumnHints = Array<FinishedMarking>()
    
    // Public API
//    init(matrixSize: (row: Int, column: Int)) {
//        matrix = Array(repeating: Array(repeating: Cell.Unknown, count: matrixSize.column), count: matrixSize.row)
//    }
    init(rowHints: [Array<Int>], columnHints: [Array<Int>]) {
        let rowCount = rowHints.count
        let columnCount = columnHints.count
        matrix = Array(repeating: Array(repeating: Cell.unknown, count: columnCount), count: rowCount)
        _hintsForRows = rowHints
        _hintsForColumns = columnHints
        isFinishedMarkingWithRowHints = Array(repeating: FinishedMarking.notFinished, count: rowCount)
        isFinishedMarkingWithColumnHints = Array(repeating: FinishedMarking.notFinished, count: columnCount)
    }
    
    // computed properties
    var W: Int { return matrix.first?.count ?? 0 }
    var H: Int { return matrix.count }
    var H_columnHints: Int {
        return _hintsForColumns.reduce(0, { max($0, $1.count) })
    }
    var W_rowHint: Int {
        return _hintsForRows.reduce(0, { max($0, $1.count) })
    }
    var hintsForRows: [Array<Int>] {
        get {
            return _hintsForRows
        }
    }
    var hintsForColumns: [Array<Int>] {
        get { return _hintsForColumns }
    }
    
    
    func hintsForRowAt(_ rowIndex: Int) -> Array<Int> {
        return _hintsForRows[rowIndex]
    }
    
    func hintsForColumnAt(_ columnIndex: Int) -> Array<Int> {
        return _hintsForColumns[columnIndex]
    }

    func cellAt(_ rowIndex: Int, _ columnIndex: Int) -> Cell? {

        if (rowIndex <= H && columnIndex <= W) {
            return matrix[rowIndex][columnIndex]
        } else {
            return nil
        }
    }
    
    mutating func toggleCellAt(_ rowIndex: Int, _ columnIndex: Int) {
        if (rowIndex <= H && columnIndex <= W) {
            let selectedCell = matrix[rowIndex][columnIndex]
            matrix[rowIndex][columnIndex] = selectedCell.toggle
        } else {
            print("toggleCellAt: (\(rowIndex), \(columnIndex))")
        }
    }
    
    var description: String {
        var result = ""
        
        // print column hints
        let H_columnHints = hintsForColumns.reduce(0, { max($0, $1.count) })
        //print(maxHintNum)
        for h in stride(from: H_columnHints, to: 0, by: -1) {
            for w in 0..<W {
                if hintsForColumns[w].count < h {
                    result = result + "⬚"
                } else {
                    let enclosedNumber = String(hintsForColumns[w][h-1]) + "\u{20DD}"
                    result = result + enclosedNumber
                }
            }
            result = result + "\n"
        }
        
        // print matrix & row hints
        for rowIndex in (0..<matrix.count) {
            let aRow = matrix[rowIndex]
            for aCell in aRow {
                result = result + aCell.description
            }
            // print row hints
            result = result + _hintsForRows[rowIndex].reduce("", { (hints: String, mark: Int) -> String in
                hints + " " + String(mark)
            })
            result = result + "\n"
        }
        result.removeLast()
        return result
    }
    
    

    mutating func updateRow(newRowInfo: Array<Cell>, at rowIndex: Int) {
        assert(newRowInfo.count == W, "row size is wrong:\(W) vs \(newRowInfo.count)")
        for offset in 0..<W {
            if (matrix[rowIndex][offset] == .unknown && newRowInfo[offset] != .unknown) {
                matrix[rowIndex][offset] = newRowInfo[offset]
            }
        }
    }
    mutating func updateColumn(newColumnInfo: Array<Cell>, at columnIndex: Int) {
        assert(newColumnInfo.count == H, "column size is wrong:\(H) vs \(newColumnInfo.count)")
        for offset in 0..<H {
            if (matrix[offset][columnIndex] == .unknown && newColumnInfo[offset] != .unknown) {
                matrix[offset][columnIndex] = newColumnInfo[offset]
            }
        }
    }
    mutating func setColumn(aColumn: Array<Cell>, at columnIndex: Int) {
        assert(aColumn.count == H, "$_: cloumn doesn't fit")
    }

    func rowAt(rowIndex: Int) -> Array<Cell> {
        return matrix[rowIndex]
    }
    // FIX ME: it takes time
    func columnAt(columnIndex: Int) -> Array<Cell> {
        return (0..<H).map{ rowIndex in
            matrix[rowIndex][columnIndex]
        }
    }
    
    enum HintDirection {
        case column
        case row
    }
    
    mutating func firstMarkingFromHintsOf(_ hintDirection: HintDirection) {
        let allTargetCount: Int
        let eachTargetSize: Int
        let hints: [Array<Int>]

        switch hintDirection {
        case .column:
            allTargetCount = W
            eachTargetSize = H
            hints = _hintsForColumns
        case .row:
            allTargetCount = H
            eachTargetSize = W
            hints = _hintsForRows
        }
        
        for targetIndex in 0..<allTargetCount {
            let hint = hints[targetIndex]
            
            // check whether it is worth to look into
            // 첫 윈도우와 마지막 슬라이드 윈도우가 겹치지 않을 경우 마킹을 확정 지을 수 없음
            let windowSize = hint.reduce(0, { $0 + $1 }) + hint.count - 1
            let maxMarkNum = hint.reduce(0, { max($0, $1) })
            if windowSize * 2 <= eachTargetSize {
                //print("rowIndex:\(rowIndex) windowSize:\(windowSize)")
                continue
            }
            // 윈도우가 겹쳐도 마킹영역이 겹치지 않음
            let slideCount = eachTargetSize - windowSize
            if maxMarkNum <= slideCount {
                //print("rowIndex:\(rowIndex) maxMarkNum:\(maxMarkNum) slideCount:\(slideCount) windowSize:\(windowSize)")
                continue
            }
            
            // prepare sliding block
            var window = Array<Cell>()
            for straightMarkings in hint {
                window.append(contentsOf: repeatElement(Cell.marked, count: straightMarkings))
                window.append(Cell.blank)
            }
            window.removeLast() // remove last white blank
            
            // searck safe marks by sliding window in a row
            //var aRow = rowAt(rowIndex: rowIndex)
            var workplaceForMarking = Array(repeatElement(Cell.unknown, count: W))
            var hasBeenUnchanged = Array(repeatElement(true, count: W))
            // copy to workplace, check before slide
            for i in 0..<window.count {
                workplaceForMarking[i] = window[i]
            }
            if (window.count < eachTargetSize) {
                // set behind of window
                for i in window.count..<W {
                    hasBeenUnchanged[i] = false
                }
                // set in front of window at last slide position
                for i in 0..<eachTargetSize - window.count {
                    hasBeenUnchanged[i] = false
                    workplaceForMarking[i] = Cell.unknown
                }
            }
            // check slide
            for slideOffset in 1...(eachTargetSize - window.count) {
                for iWindow in 0..<window.count {
                    let iMark = slideOffset + iWindow
                    if (hasBeenUnchanged[iMark] == true) {
                        if workplaceForMarking[iMark] != window[iWindow] {
                            hasBeenUnchanged[iMark] = false
                            workplaceForMarking[iMark] = Cell.unknown
                        }
                    }
                }
            }
            
            // update matrix
            if hintDirection == .row {
                updateRow(newRowInfo: workplaceForMarking, at: targetIndex)
            } else {
                updateColumn(newColumnInfo: workplaceForMarking, at: targetIndex)
            }
        }
    }
    
    mutating func solve() {
        firstMarkingFromHintsOf(.row)
        firstMarkingFromHintsOf(.column)
    }
}
