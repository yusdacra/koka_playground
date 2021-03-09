use std::collections::HashMap;
fn main() {
    let (mut stack, mut dict, mut defining) = (Vec::new(), HashMap::<String, Vec<String>>::new(), None);
    let code = std::fs::read_to_string(std::env::args().nth(1).expect("no file provided")).expect("couldnt read file");
    let words = code.split(" ").map(|s| s.trim().to_string()).collect::<Vec<_>>();
    for (i, word) in words.iter().enumerate() {
        match defining {
            Some(def_index) => {
                let def_word = words.get(def_index + 1).expect("no def word name");
                if i != def_index {
                    if word == ";" {
                        defining = None;
                    } else {
                        match dict.get_mut(def_word) {
                            Some(v) => v.push(word.clone()),
                            None => {dict.insert(def_word.clone(), vec![word.clone()]);},
                        }
                    }
                }
            }
            None => if do_word(&mut stack, word) {
                        match word.as_str() {
                            ":" => if defining.is_none() { defining = Some(i); },
                            _ => for w in dict.get(word).expect("no such word"){do_word(&mut stack,w);}
                        }
                    }
        }
    }
}
fn do_word(stack: &mut Vec<i64>, word: &str) -> bool {
    match word {
        "." => print!("{} ", su(stack.pop())),
        "emit" => print!("{}", su(stack.pop()) as u8 as char),
        "cr" => println!(),
        "+" => do_op(stack, |f, s| vec![f + s]),
        "-" => do_op(stack, |f, s| vec![f - s]),
        "*" => do_op(stack, |f, s| vec![f * s]),
        "/" => do_op(stack, |f, s| vec![f / s]),
        "<" => do_op(stack, |f, s| vec![if f < s { -1 } else { 0 }]),
        ">" => do_op(stack, |f, s| vec![if f > s { -1 } else { 0 }]),
        "=" => do_op(stack, |f, s| vec![if f == s { -1 } else { 0 }]),
        "&" => do_op(stack, |f, s| vec![f & s]),
        "|" => do_op(stack, |f, s| vec![f | s]),
        "dup" => stack.push(*su(stack.last())),
        "drop" => {su(stack.pop());},
        "swap" => do_op(stack, |f, s| vec![f, s]),
        "over" => do_op(stack, |f, s| vec![s, f, s]),
        "rot" => {stack.push(*su(stack.get(stack.len() - 3)));stack.remove(stack.len() - 4);},
        _ => match word.parse::<i64>(){Ok(num)=>stack.push(num),Err(_)=>return true,}
    }
    false
}
fn do_op(stack: &mut Vec<i64>, op: fn(i64, i64) -> Vec<i64>){let mut res=op(su(stack.pop()),su(stack.pop()));stack.append(&mut res)}
fn su<T>(val: Option<T>) -> T { val.expect("stack underflow") }