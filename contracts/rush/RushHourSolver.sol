// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "hardhat/console.sol";

contract RushHourSolver {
    struct Grid {
        uint8[6][6] state;
    }

    struct Position {
        uint8 x;
        uint8 y;
    }

    struct Move {
        Position current;
        uint action; //4: down 3: up 1: left 2: right
    }

    function RushHourSolve(
        uint8[6][6] memory initialGrid
    ) public view returns (bool) {
        Grid[] memory queue = new Grid[](100);
        Grid[] memory visited = new Grid[](100);
        uint forward = 0;
        uint backward = 0;

        for (uint i = 0; i < 6; i++)
            for (uint j = 0; j < 6; j++)
                visited[forward].state[i][j] = queue[forward].state[i][
                    j
                ] = initialGrid[i][j];
        backward = 1;
        while (forward < backward) {
            console.log(forward, backward);
            Grid memory currentGrid = queue[forward];
            console.log("f1");
            Position[] memory emptyBlocks = findEmptyBlocks(currentGrid);
            console.log(
                "----------------------------------",
                emptyBlocks.length
            );
            if (forward == 23) {
                for (uint ii = 0; ii < 6; ii++)
                    for (uint jj = 0; jj < 6; jj++)
                        console.log(
                            "%d %d = %d",
                            ii,
                            jj,
                            currentGrid.state[ii][jj]
                        );
            }
            for (uint i = 0; i < emptyBlocks.length; i++) {
                Move[] memory neighbors = findNeighbors(
                    currentGrid,
                    emptyBlocks[i]
                );
                // console.log(emptyBlocks[i].x, emptyBlocks[i].y);
                for (uint j = 0; j < neighbors.length; j++) {
                    Grid memory newGrid = moveVehicle(
                        currentGrid,
                        neighbors[j].current,
                        emptyBlocks[i]
                    );
                    console.log(
                        "Move == ",
                        neighbors[j].current.x,
                        " ",
                        neighbors[j].current.y
                    );
                    if (!isVisited(visited, backward, newGrid)) {
                        console.log("no visited");
                        for (uint ii = 0; ii < 6; ii++){
                            for (uint jj = 0; jj < 6; jj++) {
                                console.log(ii, jj);
                                queue[backward].state[ii][jj] = newGrid.state[
                                    ii
                                ][jj];
                            }
                        }
                        for (uint ii = 0; ii < 6; ii++)
                            for (uint jj = 0; jj < 6; jj++)
                                visited[backward].state[ii][jj] = newGrid.state[
                                    ii
                                ][jj];
                        backward++;
                        if (newGrid.state[2][5] == 1) {
                            // Assuming the target vehicle reaches position (2, 5) for a win
                            console.log("Finished");
                            return true;
                        }
                    } else {
                        console.log("visited");
                    }
                }
            }
            forward++;
            console.log("************************************");
        }
        console.log("UnFinished");
        return false;
    }

    function isVisited(
        Grid[] memory visited,
        uint cnt,
        Grid memory current
    ) private pure returns (bool) {
        for (uint i = 0; i < cnt; i++) {
            if (compareGrids(visited[i], current)) {
                return true;
            }
        }
        return false;
    }

    function compareGrids(
        Grid memory grid1,
        Grid memory grid2
    ) private pure returns (bool) {
        if (grid1.state.length != grid2.state.length) {
            return false;
        }

        for (uint i = 0; i < grid1.state.length; i++) {
            if (grid1.state[i].length != grid2.state[i].length) {
                return false;
            }

            for (uint j = 0; j < grid1.state[i].length; j++) {
                if (grid1.state[i][j] != grid2.state[i][j]) {
                    return false;
                }
            }
        }

        return true;
    }

    function findEmptyBlocks(
        Grid memory currentGrid
    ) private pure returns (Position[] memory) {
        Position[] memory emptyBlocks = new Position[](36);
        uint cnt = 0;
        for (uint8 i = 0; i < 6; i++)
            for (uint8 j = 0; j < 6; j++) {
                if (currentGrid.state[i][j] == 0) {
                    Position memory newPos;
                    newPos.x = i;
                    newPos.y = j;
                    emptyBlocks[cnt].x = newPos.x;
                    emptyBlocks[cnt++].y = newPos.y;
                }
            }
        Position[] memory res = new Position[](cnt);
        for (uint8 i = 0; i < cnt; i++) res[i] = emptyBlocks[i];
        return res;
    }

    function findNeighbors(
        Grid memory grid,
        Position memory pos
    ) private pure returns (Move[] memory) {
        Move[] memory neighbors = new Move[](4);
        uint8 i;
        uint8 o = 0;
        uint8 row = pos.x;
        uint8 col = pos.y;
        uint cnt = 0;
        if (
            row > 1 &&
            grid.state[row - 1][col] != 0 &&
            grid.state[row - 1][col] == grid.state[row - 2][col]
        ) {
            for (
                i = row - 2;
                i >= 0 && grid.state[i][col] == grid.state[row - 1][col];
                i--
            ) {
                if (i == 0) {
                    o = 1;
                    break;
                }
            }
            Move memory newMove;
            newMove.current.x = i + 1;
            if (o == 1) newMove.current.x = 0;
            newMove.current.y = col;
            newMove.action = 4;
            neighbors[cnt] = newMove;
            cnt++;
        }
        if (
            row < 4 &&
            grid.state[row + 1][col] != 0 &&
            grid.state[row + 1][col] == grid.state[row + 2][col]
        ) {
            for (
                i = row + 2;
                i < 6 && grid.state[i][col] == grid.state[row + 1][col];
                i++
            ) {}
            Move memory newMove;
            newMove.current.x = i - 1;
            newMove.current.y = col;
            newMove.action = 3;
            neighbors[cnt] = newMove;
            cnt++;
        }
        if (
            col > 1 &&
            grid.state[row][col - 1] != 0 &&
            grid.state[row][col - 1] == grid.state[row][col - 2]
        ) {
            o = 0;
            for (
                i = col - 2;
                i >= 0 && grid.state[row][i] == grid.state[row][col - 1];
                i--
            ) {
                if (i == 0) {
                    o = 1;
                    break;
                }
            }
            Move memory newMove;
            newMove.current.y = i + 1;
            if (o == 1) newMove.current.y = 0;
            newMove.current.x = row;
            newMove.action = 2;
            neighbors[cnt] = newMove;
            cnt++;
        }
        if (
            col < 4 &&
            grid.state[row][col + 1] != 0 &&
            grid.state[row][col + 1] == grid.state[row][col + 2]
        ) {
            for (
                i = col + 2;
                i < 6 && grid.state[row][i] == grid.state[row][col + 1];
                i++
            ) {}
            Move memory newMove;
            newMove.current.x = row;
            newMove.current.y = i - 1;
            newMove.action = 1;
            neighbors[cnt] = newMove;
            cnt++;
        }
        Move[] memory res = new Move[](cnt);
        for (i = 0; i < cnt; i++) res[i] = neighbors[i];
        return res;
    }

    function moveVehicle(
        Grid memory grid,
        Position memory pos,
        Position memory empty
    ) private pure returns (Grid memory) {
        Grid memory newGrid;
        for (uint i = 0; i < 6; i++)
            for (uint j = 0; j < 6; j++) newGrid.state[i][j] = grid.state[i][j];
        newGrid.state[empty.x][empty.y] = newGrid.state[pos.x][pos.y];
        newGrid.state[pos.x][pos.y] = 0;
        return newGrid;
    }
}
