//! Repeated String
//! https://www.hackerrank.com/challenges/repeated-string/problem

fn repeated_string(s: &str, n: usize) -> usize {
    let in_length = s.len();
    let multiplier = n / in_length;
    
    let diff_length = n - (in_length * multiplier);
    let lock_value = s.matches("a").count() * multiplier;
    let last_pattern = &s[..diff_length];
    let lock_value = lock_value + last_pattern.matches("a").count();
    lock_value
}

fn main() {
    let mut s = String::new();
    let mut n = String::new();

    std::io::stdin().read_line(&mut s)
      .expect("Failed to read the line");

    let s: &str = s.trim();

    std::io::stdin().read_line(&mut n)
        .expect("Failed to read the line");

    let n: usize = match n.trim().parse() {
        Ok(num) => num,
        Err(_) => return,
    }; 

    let out = repeated_string(s, n);
    println!("{}", out);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn check_case_1() {
        let out = repeated_string("aba", 10);
        assert_eq!(out, 7);
    }

    #[test]
    fn check_case_2() {
        let out = repeated_string("a", 1000000000000);
        assert_eq!(out, 1000000000000);
    }
}