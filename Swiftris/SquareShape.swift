//
//  SquareShape.swift
//  Swiftris
//
//  Created by John Law on 10/12/15.
//  Copyright © 2015 Chi Hon Law. All rights reserved.
//

class SquareShape:Shape {
    /*
    // The bottom blocks will always be the third and fourth block as described:
    | 0•| 1 |
    | 2 | 3 |
    
    • marks the row/column indicator for the shape
    
    */
    
    // The square shape will not rotate
    
    // we've overridden the blockRowColumnPositions computed property to provide a full dictionary of tuple arrays. Each index of the arrays represents one of the four blocks ordered from block 0 to block 3. For example, the top-left block location – block 0 – of a square is exactly identical to its row and column location. Therefore the tuple is (0, 0), 0 column difference and 0 row difference. The second block is always 1 column to the right of the shape's given column value, therefore its tuple is always (1, 0).
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero: [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.OneEighty: [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.Ninety: [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.TwoSeventy: [(0, 0), (1, 0), (0, 1), (1, 1)]
        ]
    }
    
    // we perform a similar override by providing a dictionary of bottom block arrays. As was stated earlier, a square shape does not rotate, therefore its bottom-most blocks are consistently the third and fourth blocks
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:  [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:     [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}
