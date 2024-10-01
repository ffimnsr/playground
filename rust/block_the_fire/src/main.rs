type Grid = Vec<Vec<u8>>;
type Position = (usize, usize);

fn place_wall_to_block_fire(grid: &mut Grid, start: Position) -> bool {
    let rows = grid.len();
    let cols = grid[0].len();
    let directions = [
        ( 0,  1),
        ( 0, -1),
        ( 1,  0),
        (-1,  0),
        ( 1,  1),
        (-1, -1),
        ( 1, -1),
        (-1,  1),
    ];

    // Create a visited matrix to keep track of visited cells
    let mut visited = vec![vec![false; cols]; rows];
    let (r, c) = start;
    visited[r][c] = true;

    if (r, c) == (rows - 1, cols - 1) {
        return true;
    }

    for &(dr, dc) in &directions {
        let nr = r as isize + dr;
        let nc = c as isize + dc;

        if nr >= 0 && nr < rows as isize && nc >= 0 && nc < cols as isize {
            let (nr, nc) = (nr as usize, nc as usize);
            if (nr, nc) == (rows - 1, cols - 1) {
                return true;
            }

            // Fire spreads as can't build a wall on a person
            if grid[nr][nc] == b'P' {
                return true;
            }

            if grid[nr][nc] == b'.' && !visited[nr][nc] {
                grid[nr][nc] = b'#';
                visited[nr][nc] = true;
            }
        }
    }

    false
}

fn can_reach_exit(grid: &mut Grid) -> bool {
    let rows = grid.len();
    let cols = grid[0].len();

    // Place walls to block the path from any reachable fire to the exit
    for r in 0..rows {
        for c in 0..cols {
            if grid[r][c] == b'F' {
                println!("Fire at ({}, {})", r, c);
                if place_wall_to_block_fire(grid, (r, c)) {
                    return false;
                }
            }
        }
    }

    true
}

fn main() {
    let mut grid = vec![
        vec![b'.', b'.', b'.', b'.', b'.', b'.'],
        vec![b'F', b'.', b'P', b'.', b'.', b'.'],
        vec![b'.', b'.', b'.', b'P', b'.', b'.'],
        vec![b'.', b'F', b'.', b'P', b'.', b'.'],
        vec![b'.', b'.', b'.', b'.', b'.', b'.'],
        vec![b'.', b'.', b'F', b'.', b'.', b'.'],
        vec![b'.', b'.', b'.', b'.', b'.', b'.'],
    ];

    if !can_reach_exit(&mut grid) {
        println!("===> Can't exit");
    } else {
        println!("===> Can exit");
    }

    println!();
    for row in grid {
        for cell in row {
            print!("{}", char::from_u32(cell as u32).unwrap_or(' '));
        }
        println!();
    }
}
