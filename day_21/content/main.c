#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

typedef struct monkey {
	char name[4];

	bool has_number;
	bool is_you;

	union {
		struct names {
			char *first;
			char *second;
			char operator;
		} names;
		struct operation {
			struct monkey* first;
			struct monkey* second;
			char operator;
		} operation;
		size_t number;
	} value;

} Monkey;

char** split(char* str, size_t* len) {
	unsigned segment = 1;
	for(size_t i = 0; i < *len; ++i) {
		if (str[i] == '\n') {
			++segment;
		}
	}
	char** segments = malloc(segment * sizeof(char*));
	segment = 0;
	segments[0] = str;
	for (size_t i = 0; i < *len; ++i) {
		if (str[i] == '\n') {
			++segment;
			segments[segment] = str + i + 1;
			str[i] = '\0';
		}
	}
	*len = segment + 1; 
	return segments;
}

int compare_name(const char* a, const char* b) {
	for (unsigned i = 0; i < 4; ++i) {
		if (a[i] > b[i]) return 1;
		if (a[i] < b[i]) return -1;
	}
	return 0;
}

void sort(Monkey* monkeys, const size_t start, const size_t len) {
	if (len == 1) {
		return;
	}
	if (len == 2) {
		if (compare_name(monkeys[start].name, monkeys[start + len - 1].name) == -1) {
			Monkey temp = monkeys[start];
			monkeys[start] = monkeys[start + len - 1];
			monkeys[start + len  -1] = temp;
		}
		return;
	}
	Monkey* parts = malloc(sizeof(Monkey) * len);
	memcpy(parts, monkeys + start, len * sizeof(Monkey));
	size_t start_1 = 0;
	size_t start_2 = len / 2;
	const size_t len_1 = len / 2;
	const size_t len_2 = (len + 1) / 2;
	sort(parts, start_1, len_1); 
	sort(parts, start_2, len_2);
	for (size_t i = start; i < start + len; ++i) {
		if (start_1 == len_1) {
			monkeys[i] = parts[start_2];
			++start_2;
		} else if (start_2 - len_1 == len_2) {
			monkeys[i] = parts[start_1];
			++start_1;
		} else if (compare_name(parts[start_1].name, parts[start_2].name) == 1) {
			monkeys[i] = parts[start_1];
			++start_1;
		} else {
			monkeys[i] = parts[start_2];
			++start_2;	
		}
	}
	free(parts);
}

Monkey* binsearch(Monkey* monkeys, const size_t len, const char* name) {
	size_t lower = 0;
	size_t upper = len -1;
	while (lower != upper) {
		const size_t middle = (lower + upper) / 2;
		const int cmp = compare_name(name, monkeys[middle].name);
		if (cmp == 0) {
			return monkeys + middle;
		}
		if (cmp > 0) {
			upper = middle;
		} else {
			lower = middle + 1;
		}
	}
	if (compare_name(name, monkeys[lower].name) != 0) {
		return NULL;
	}
	return monkeys + lower;
}

size_t eval(Monkey* monkey) {
	if (monkey->has_number) {
		return monkey->value.number;
	} else {
		size_t first = eval(monkey->value.operation.first);
		size_t second = eval(monkey->value.operation.second);
		switch (monkey->value.operation.operator) {
			case '*':
				return first * second;
			case '/':
				return first / second;
			case '+':
				return first + second;
			case '-':
				return first - second;
		}
		
	}
}

void solve(Monkey* monkey) {
	if (monkey->is_you) {
		monkey->has_number = false;
		return;
	}
	if (monkey->has_number) {
		return;
	} else {
		solve(monkey->value.operation.first);
		solve(monkey->value.operation.second);
		if (monkey->value.operation.first->has_number && monkey->value.operation.second->has_number) {
			size_t value = eval(monkey);
			monkey->has_number = true;
			monkey->value.number = value;
		}
		
	}
}

size_t match(Monkey* monkey, size_t val) {
	if (monkey->is_you) {
		return val;
	}
	Monkey* first = monkey->value.operation.first;
	Monkey* second = monkey->value.operation.second;
	Monkey* target;
	size_t num;
	if (first->has_number) {
		num = first->value.number;
		target = second;
	} else {
		num = second->value.number;
		target = first;
	}
	switch (monkey->value.operation.operator) {
		case '*':
			return match(target, val / num);
		case '+':
			return match(target, val - num);
		case '-':
			if (target == first) {
				return match(target, val + num);
			} else {
				return match(target, num - val);
			}
		case '/':
			if (target == first) {
				return match(target, val * num);
			} else {
				return match(target, num / val);
			}
	}
}

int main() {
	int status = 0;
	FILE* f = fopen("../input/input21.txt", "r");

	fseek(f, 0, SEEK_END);
	size_t len = ftell(f);
	fseek(f, 0, SEEK_SET);

	char* buffer = (char*)malloc(len + 1);
	if (fread(buffer, 1, len, f) != len) {
		printf("Failed to read file\n");
		status = -1;
		goto end;
	}

	char** lines = split(buffer, &len);
	if (lines[len - 1][0] == '\0') {
		len -= 1;
	}
	Monkey* monkeys = malloc(len * sizeof(Monkey));

	for (size_t i = 0; i < len; ++i) {
		char* line = lines[i];
		strncpy(monkeys[i].name, line, 4); 
		monkeys[i].is_you = false;
		if (line[6] >= '0' && line[6] <= '9') {
			monkeys[i].value.number = atol(line + 6);
			monkeys[i].has_number = true;
		} else {
			monkeys[i].has_number = false;
			monkeys[i].value.names.first = line + 6;
			monkeys[i].value.names.second = line + 13;
			monkeys[i].value.names.operator = line[11];
		}
	}

	sort(monkeys, 0, len);

	for (size_t i = 0; i < len; ++i) {
		if (!monkeys[i].has_number) {
			char operator = monkeys[i].value.names.operator;
			Monkey* first = binsearch(monkeys, len, monkeys[i].value.names.first);
			Monkey* second = binsearch(monkeys, len, monkeys[i].value.names.second);
			monkeys[i].value.operation.first = first;
			monkeys[i].value.operation.second = second;
			monkeys[i].value.operation.operator = operator;
		}
	}

	Monkey* root = binsearch(monkeys, len, "root");
	printf("%llu\n", eval(root));
	
	binsearch(monkeys, len, "humn")->is_you = true;
	solve(root);
	size_t target;
	if (root->value.operation.first->has_number) {
		target = match(root->value.operation.second, root->value.operation.first->value.number);
	} else {
		target = match(root->value.operation.first, root->value.operation.second->value.number);
	}

	printf("%llu\n", target);

	free(monkeys);
	free(lines);
end:
	fclose(f);
	free(buffer);
	return status;
}