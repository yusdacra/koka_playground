use std::collections::HashMap;
enum Action {
    Defining(usize),
    Saying,
    None,
}
impl Action {
    fn is_none(&self) -> bool {
        matches!(self, Action::None)
    }
}
impl Default for Action {
    fn default() -> Self {
        Action::None
    }
}
fn main() {
    let (mut stack, mut dict, mut defining) = Default::default();
    let code = std::fs::read_to_string(std::env::args().nth(1).expect("no file provided"))
        .expect("couldnt read file");
    let words = code
        .split(|c| c == ' ' || c == '\n')
        .filter_map(|s| {
            let new = s.trim().to_string();
            if new.is_empty() {
                None
            } else {
                Some(new)
            }
        })
        .collect::<Vec<_>>();
    for (i, word) in words.iter().enumerate() {
        do_word(&words, &mut stack, &mut dict, &mut defining, word, i);
    }
}
fn do_word(
    words: &Vec<String>,
    stack: &mut Vec<i64>,
    dict: &mut HashMap<String, Vec<String>>,
    defining: &mut Action,
    word: &str,
    i: usize,
) {
    match defining {
        Action::Saying => {
            if word != "\"" {
                print!("{} ", word)
            } else {
                *defining = Action::None;
            }
        }
        Action::Defining(def_index) => {
            let def_word = words.get(*def_index + 1).expect("no def word name");
            if i != *def_index + 1 {
                if word == ";" {
                    *defining = Action::None;
                } else {
                    match dict.get_mut(def_word) {
                        Some(v) => v.push(word.to_string()),
                        None => {
                            dict.insert(def_word.clone(), vec![word.to_string()]);
                        }
                    }
                }
            }
        }
        Action::None => match word {
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
            "drop" => {
                su(stack.pop());
            }
            "swap" => do_op(stack, |f, s| vec![f, s]),
            "over" => do_op(stack, |f, s| vec![s, f, s]),
            "rot" => {
                stack.push(*su(stack.get(stack.len() - 3)));
                stack.remove(stack.len() - 4);
            }
            ":" => {
                if defining.is_none() {
                    *defining = Action::Defining(i);
                }
            }
            ".\"" => {
                if defining.is_none() {
                    *defining = Action::Saying;
                }
            }
            _ => match word.parse::<i64>() {
                Ok(num) => stack.push(num),
                Err(_) => {
                    for w in dict.get(word).expect("no such word").clone() {
                        do_word(words, stack, dict, defining, w.as_str(), i)
                    }
                }
            },
        },
    }
}
fn do_op(stack: &mut Vec<i64>, op: fn(i64, i64) -> Vec<i64>) {
    let mut res = op(su(stack.pop()), su(stack.pop()));
    stack.append(&mut res)
}
fn su<T>(val: Option<T>) -> T {
    val.expect("stack underflow")
}
