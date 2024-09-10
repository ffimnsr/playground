//! Jumping on the Clouds
//! https://www.hackerrank.com/challenges/jumping-on-the-clouds/problem

fn jump(count: i32, prev_val: i32, curr_pos: usize, n: usize,  c: Vec<i32>) -> i32 {
    if curr_pos <= n {
        if c[curr_pos] == 0 {
            println!("j pos {}, c {}", curr_pos, c[curr_pos]);
            jump(count + 1, curr_pos + 1, n, c)
        } else {
            println!("n pos {}, c {}", curr_pos, c[curr_pos]);
            jump(count, curr_pos + 1, n, c)
        }
    } else {
        count
    }
}

fn jumping_on_clouds(n: usize, c: Vec<i32>) -> i32 {
    jump(0, c[0], 1, n, c)
}

fn main() {
    let mut n = String::new();
    let mut c = String::new();

    std::io::stdin().read_line(&mut n)
      .expect("Failed to read the line");

    let n: usize = match n.trim().parse() {
      Ok(num) => num,
      Err(_) => return,
    }; 

    std::io::stdin().read_line(&mut c)
        .expect("Failed to read the line");

    let c: Vec<i32> = c.trim()
        .split_whitespace()
        .map(|s| s.parse().unwrap())
        .collect::<Vec<i32>>();

    let out = jumping_on_clouds(n, c);
    println!("{}", out);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn check_case_1() {
        let out = jumping_on_clouds(6, vec![0, 1, 0, 0, 0, 1, 0]);
        assert_eq!(out, 3);
    }

    #[test]
    fn check_case_2() {
        let out = jumping_on_clouds(7, vec![0, 0, 1, 0, 0, 1, 0]);
        assert_eq!(out, 4);
    }

    #[test]
    fn check_case_3() {
        let out = jumping_on_clouds(6, vec![0, 0, 0, 0, 1, 0]);
        assert_eq!(out, 3);
    }
}