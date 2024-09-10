use rand::seq::SliceRandom;

fn main() {
    let mut rng = rand::thread_rng();
    let mut numbers: Vec<u32> = (1..51).collect();
    numbers.shuffle(&mut rng);
    
    println!("Shuffled: {:?}", numbers);
}
