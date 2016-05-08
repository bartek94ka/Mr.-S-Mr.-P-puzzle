from collections import Counter


all_pairs = set((a, b) for a in range(2, 98) for b in range(a + 1, 99) if a + b <= 200)
print("1. ", all_pairs)


def decompose_sum(s):
    return [(a, s - a) for a in range(2, int(s / 2 + 1))]


_prod_counts = Counter(a * b for a, b in all_pairs)
unique_products = set((a, b) for a, b in all_pairs if _prod_counts[a * b] == 1)

print("2. ", unique_products)

# Find all pairs, for which no sum decomposition has unique product
# In other words, for which all sum decompositions have non-unique product
sum_pairs = [(a, b) for a, b in all_pairs if
             all((x, y) not in unique_products for (x, y) in decompose_sum(a + b))]

# Since product guy now knows, possible pairs are those out of above for which product is unique
product_pairs = [(a, b) for a, b in sum_pairs if Counter(c * d for c, d in sum_pairs)[a * b] == 1]

print("3. ", product_pairs)

# Since the sum guy now knows
final_pairs = [(a, b) for a, b in product_pairs if Counter(c + d for c, d in product_pairs)[a + b] == 1]

# [(4, 13)]
print(final_pairs)
