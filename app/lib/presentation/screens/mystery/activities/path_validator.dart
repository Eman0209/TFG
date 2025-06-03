import 'package:app/presentation/widgets/pipe.dart';

class PathValidator {
  static bool isConnected(List<List<PipeTile>> grid) {
    int n = grid.length;
    Set<String> visited = {};
    return _dfs(grid, 0, 0, visited);
  }

  static bool _dfs(List<List<PipeTile>> grid, int row, int col, Set<String> visited) {
    int n = grid.length;
    if (row < 0 || col < 0 || row >= n || col >= n) return false;

    String key = '$row,$col';
    if (visited.contains(key)) return false;
    visited.add(key);

    if (row == n - 1 && col == n - 1) return true;

    PipeTile tile = grid[row][col];

    for (Direction dir in tile.connections) {
      int newRow = row;
      int newCol = col;
      Direction opposite;

      switch (dir) {
        case Direction.up:
          newRow--;
          opposite = Direction.down;
          break;
        case Direction.down:
          newRow++;
          opposite = Direction.up;
          break;
        case Direction.left:
          newCol--;
          opposite = Direction.right;
          break;
        case Direction.right:
          newCol++;
          opposite = Direction.left;
          break;
      }

      if (newRow >= 0 && newCol >= 0 &&
          newRow < n && newCol < n &&
          grid[newRow][newCol].connections.contains(opposite)) {
        if (_dfs(grid, newRow, newCol, visited)) return true;
      }
    }

    return false;
  }
}
