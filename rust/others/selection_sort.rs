//! Selection Sort

#[allow(dead_code)]
fn selection_sort(mut arr: Vec<i32>) -> Vec<i32> {
    let arr_len = arr.len();
    for i in 0..arr_len {
        let mut temp: usize = i;
        for j in (i + 1)..arr_len {
            if arr[temp] > arr[j] {
                temp = j;
            }
        }
        arr.swap(i, temp); 
    }
    arr
}

fn main() {
    unimplemented!();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn check_case_1() {
        let out = selection_sort(vec![64, 25, 12, 22, 11]);
        assert_eq!(out, vec![11, 12, 22, 25, 64]);
    }
}
