//
//  MatrixViewController.swift
//  LogicGame2
//
//  Created by KimYusung on 2017/12/09.
//  Copyright © 2017 yusungkim. All rights reserved.
//

import UIKit

enum GameComponent {
    case markingCell(Cell, rowIndex:Int, columnIndex:Int)
    case rowHint(Int?)
    case columnHint(Int?)
    case nothing
}

class MatrixViewController: UICollectionViewController {

    // MARK: - Properties
    private let reuseIdentifier = "MatrixViewCell"
    private let gridLineSpace = CGFloat(1.0)
    //private var sectionInsets = UIEdgeInsetsMake(gridLineSpace, gridLineSpace, gridLineSpace, gridLineSpace)
    private var itemsPerRow = 10 // will reset when gameMatrix set
    
    // MARK: - Model
    private var gameMatrix: Matrix! {
        didSet {
            itemsPerRow = gameMatrix.W + gameMatrix.W_rowHint
            //print("\(itemsPerRow) = \(gameMatrix.W) + \(gameMatrix.W_rowHint)")
            collectionView?.reloadData()
            navigationItem.title = "Logic Game (\(gameMatrix.W)X\(gameMatrix.H))"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//         self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        // lowIndex -> highIndex : HintFromLeft -> HintFromRight
        let hintsForRows = [
            [1,2],
            [1,1,1,1],
            [1,1,1,3,1],
            [3,2,1,3],
            [3,2,4,1],
            [3,8],
            [2,2,4,1],
            [2,1,2,4],
            [2,1,2,4],
            [6,2,3],
            [8,3],
            [9,2],
            [7,1,1],
            [5,3],
            [1,1]
        ]
        // lowIndex -> highIndex : hintFromTop -> hintFromBottom
        let hintsForColumns = [
            [1],
            [1],
            [1,3,4],
            [1,2,7],
            [1,4,4],
            [1,1,1,7],
            [2,1,2,5],
            [2,2,7],
            [2,2,4],
            [6,5],
            [1,3,2,2],
            [8,2,1],
            [1,6,2],
            [4,5,1],
            [3,1,2]
        ]
        
        gameMatrix = Matrix(rowHints: hintsForRows, columnHints: hintsForColumns)
        gameMatrix.solve()
        
        // show data
        print(gameMatrix)
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // if you return 0, it will not display anything
        return gameMatrix != nil ? 1 : 0
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if gameMatrix == nil { return 0 }
        let rowCount = gameMatrix.W + gameMatrix.W_rowHint
        let columnCount = gameMatrix.H + gameMatrix.H_columnHints
        let itemCount = rowCount * columnCount
        //print ("W:\(rowCount) H:\(columnCount) itemCount: \(itemCount)")
        return itemCount
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        let gameComponent = getComponentAt(indexPath)
        
        if let matrixCell = cell as? MatrixViewCell {
            switch gameComponent {
            case .markingCell(let cellMark, _, _):
                matrixCell.cellMark = cellMark
            case .columnHint(let hintValue), .rowHint(let hintValue):
                matrixCell.hint = hintValue
            case .nothing:
                matrixCell.hint = nil
            }
            return matrixCell
        }
        return cell
    }
    
    private func getComponentAt(_ indexPath: IndexPath) -> GameComponent {
        let serialIndex = indexPath.row
        let W_forMatrix = gameMatrix.W
        let W_forRowHints = gameMatrix.W_rowHint
        let W = W_forRowHints + W_forMatrix
        let H_forColumnHints = gameMatrix.H_columnHints
        
        let mapIndexForRow = serialIndex / W
        let mapIndexForColumn = serialIndex % W
        
        //print("serialIndex:\(serialIndex), mapIndexForRow:\(mapIndexForRow), mapIndexForColumn:\(mapIndexForColumn)")
        
        let isTop = mapIndexForRow < H_forColumnHints
        let isLeft = mapIndexForColumn < W_forRowHints
        //print("\(isTop ? "top-" : "bootom-")\(isLeft ? "left":"right")")
        
        if isTop && isLeft {
            // top-left, nothing
            return GameComponent.nothing
            
        } else if isTop && !isLeft {
            // top-right, hints for column
            let hintsOfAColumn = gameMatrix.hintsForColumnAt(mapIndexForColumn - W_forRowHints)
            let indexInAColumnHint = mapIndexForRow + hintsOfAColumn.count - H_forColumnHints
            var hint: Int? = nil
            if indexInAColumnHint >= 0 && indexInAColumnHint < hintsOfAColumn.count {
                hint = hintsOfAColumn[indexInAColumnHint]
            }
            return GameComponent.columnHint(hint)
            
        } else if !isTop && isLeft {
            // bottom-right, row hints
            let rowIndex = mapIndexForRow - H_forColumnHints
            let hintsOfARow = gameMatrix.hintsForRowAt(rowIndex)
            let indexInRowHint = mapIndexForColumn - W_forRowHints + hintsOfARow.count
            var hint: Int? = nil
            if indexInRowHint >= 0 && indexInRowHint < hintsOfARow.count {
                hint = hintsOfARow[indexInRowHint]
            }
            return GameComponent.rowHint(hint)
            
        } else {
            // bottom-left, game space for marking
            let rowIndex = mapIndexForRow - H_forColumnHints
            let columnIndex = mapIndexForColumn - W_forRowHints
            let cellMark = gameMatrix.cellAt(rowIndex, columnIndex)!
            return GameComponent.markingCell(cellMark, rowIndex:rowIndex, columnIndex: columnIndex)
        }
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let gameComponent = getComponentAt(indexPath)
        switch gameComponent {
        case .markingCell(_, let rowIndex, let columnIndex):
            gameMatrix.toggleCellAt(rowIndex, columnIndex)
        default:
            break
        }
        return true
    }
    

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension MatrixViewController: UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        var length: CGFloat = collectionView.frame.width
        var insetSpace: CGFloat = 2 * gridLineSpace
        let sectionInsets = UIEdgeInsetsMake(gridLineSpace, gridLineSpace, gridLineSpace, gridLineSpace)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            if layout.scrollDirection == .horizontal {
                length = collectionView.frame.height
                insetSpace = sectionInsets.top + sectionInsets.bottom
            }
        }

        let paddingSpace = gridLineSpace * (CGFloat(itemsPerRow) + 1)
        let availableWidth = length - paddingSpace - insetSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    // collectionView(_:layout:insetForSectionAt:) returns the spacing between the cells, headers, and footers. A constant is used to store the value.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(gridLineSpace, gridLineSpace, gridLineSpace, gridLineSpace)
    }
    
    // 4
    // This method controls the spacing between each line in the layout. You want this to match the padding at the left and right.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return gridLineSpace
    }
    
    // 5
    // これがなければ、itemsPerRowが多いいとき、レイアウトがずれる
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//                if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
//                    layout.minimumLineSpacing = gridLineSpace
//                    layout.minimumInteritemSpacing = gridLineSpace
//                }
        return gridLineSpace
    }
}
