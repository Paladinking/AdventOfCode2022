import java.io.*;
import java.util.*;
import java.util.stream.Collectors;

public class Main {

	private static abstract class Item {

		public abstract int compare(Item right);

		public abstract int compareNumber(NumberItem left);

		public abstract int compareList(ListItem left);
	}

	private static class NumberItem extends Item {
		public NumberItem(String input) {
			this.value = Integer.parseInt(input);
		}

		final private int value;

		public int compare(Item right) {
			return right.compareNumber(this);
		}

		public int compareNumber(NumberItem left) {
			return Integer.compare(left.value, this.value);
		}

		public int compareList(ListItem left) {
			return left.compare(new ListItem(this));
		}
	}

	private static class ListItem extends Item {

		final private List<Item> values;

		public ListItem(String input) {
			this.values = new ArrayList<Item>();
			for (int start = 1; start < input.length() -1; start++) {
				if (input.charAt(start) == '[') {
					int end = start + 1;
					for (int openCount = 1; openCount > 0; end++) {
						if (input.charAt(end) == '[') {
							openCount++;
						} else if (input.charAt(end) == ']'){
							openCount--;
						}
					}
					values.add(new ListItem(input.substring(start, end)));
					start = end;
				} else {
					int end = input.indexOf(',', start);
					end = end == -1 ? input.length() - 1 : end;
					values.add(new NumberItem(input.substring(start, end)));
					start = end;
				}
			}
		}

		public ListItem(NumberItem value) {
			this.values = new ArrayList<Item>();
			values.add(value);
		}

		public int compare(Item right) {
			return right.compareList(this);
		}

		public int compareNumber(NumberItem left) {
			return new ListItem(left).compare(this);
		}

		public int compareList(ListItem left) {
			if (left.values.size() < this.values.size()) return left.compareList(this) * -1;
			for (int i = 0; i < this.values.size(); i++) {
				int cmp = left.values.get(i).compare(this.values.get(i));
				if (cmp != 0) {
					return cmp;
				}
			}
			return this.values.size() < left.values.size() ? 1 : 0;
		}
	}

	public static void main(String[] args) throws IOException {
		BufferedReader in = new BufferedReader(new FileReader("../input/input13.txt"));

		List<Item> items = in.lines().filter((line) -> line.length() > 0)
			.map((line) -> new ListItem(line)).collect(Collectors.toList());

		Item dividerA = new ListItem("[[2]]");
		Item dividerB = new ListItem("[[6]]");

		int sum = 0;
		for(int i = 0; i < items.size(); i += 2) {
			if (items.get(i).compare(items.get(i + 1)) < 0) {
				sum += i / 2 + 1;
			}
		}
		items.add(dividerA);
		items.add(dividerB);
		items.sort(Item::compare);

		System.out.println(sum);
		System.out.println((items.indexOf(dividerA) + 1) * (items.indexOf(dividerB) + 1));
	}
}
