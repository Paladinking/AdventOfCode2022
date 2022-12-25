use std::fs;
use std::error::Error;


fn snafu_to_int(data : &[u8]) -> i64 {
	data.into_iter().fold(0, |sum : i64, num : &u8| {
		let val = match num {
			b'-' => -1,
			b'=' => -2,
			b'0' | b'1' | b'2' => *num as i64 - b'0' as i64,
			_ => unreachable!()
		};
		5 * sum + val
	})
}

fn int_to_radix_padded(mut x: i64, radix: u32) -> Vec<u8> {
    let mut result : Vec<u8> = vec![];

    loop {
        let m = x % radix as i64;
        x = x / radix as i64;

        result.push(std::char::from_digit(m as u32, radix).unwrap() as u8);
        if x == 0 {
            break;
        }
    }
	result.push(b'0');
    result.into_iter().rev().collect()
}


fn int_to_snafu(val : i64) -> String {
	if val == 0 {
		return "0".to_string();
	}
	let mut base_5 = int_to_radix_padded(val, 5);
	let mut i = 1;
	while i < base_5.len() {
		if base_5[i] == b'.' {
			base_5[i] = b'0';
			i += 1;
		} else if base_5[i] == b'>' {
			base_5[i] = b'-';
			i += 1;
		} else if base_5[i] == b'3' {
			base_5[i - 1] += 1;
			base_5[i] = b'=';
			i -= 1;
		} else if base_5[i] == b'4' {
			base_5[i - 1] += 1;
			base_5[i] = b'-';
			i -= 1;
		} else {
			i += 1;
		}
	}
	if base_5[0] == b'0' {
		base_5.remove(0);	
	}
	return String::from_utf8(base_5).unwrap();
}

fn main() -> Result<(), Box<dyn Error>> {
	
	let text = fs::read("../input/input25.txt")?;

	let sum = text.split(|a : &u8| *a == b'\n').fold(0, |sum : i64, slice : &[u8]| sum + snafu_to_int(slice));

	println!("{}", int_to_snafu(sum));
	Ok(())
}