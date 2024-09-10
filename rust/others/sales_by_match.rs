//! Sales By Match
//! https://www.hackerrank.com/challenges/sock-merchant/problem

fn sock_merchant(n: usize, ar: Vec<i32>) -> usize {
    let mut sorted = ar.clone();
    sorted.sort();

    let mut indexes: Vec<i32> = vec![];
    let mut pair_count = 0;
    for i in 0..n {
        if indexes.contains(&(i as i32)) {
            continue;
        }
 
        indexes.push(i as i32);
        for j in 0..n {  
            if indexes.contains(&(j as i32)) {
                continue;
            }
            
            let accessed_index = j;
            if sorted[i] == sorted[accessed_index] {
                pair_count += 1;
                indexes.push(accessed_index as i32);
                break;
            }
        }
    }

    pair_count
}

fn main() {
    let mut n = String::new();
    let mut ar = String::new();

    std::io::stdin().read_line(&mut n)
      .expect("Failed to read the line");

    let n: usize = match n.trim().parse() {
      Ok(num) => num,
      Err(_) => return,
    }; 

    std::io::stdin().read_line(&mut ar)
        .expect("Failed to read the line");

    let ar: Vec<i32> = ar.trim()
        .split_whitespace()
        .map(|s| s.parse().unwrap())
        .collect::<Vec<i32>>();

    let out = sock_merchant(n, ar);
    println!("{}", out);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn check_case_1() {
        let out = sock_merchant(9, vec![10, 20, 20, 10, 10, 30, 50, 10, 20]);
        assert_eq!(out, 3);
    }
}