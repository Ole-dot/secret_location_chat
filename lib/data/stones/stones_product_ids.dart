const kStonesProductIds = [
  'stones_100',
  'stones_500',
  'stones_1000',
];

const kStonesAmountByProductId = {
  'stones_100': 100,
  'stones_500': 500,
  'stones_1000': 1000,
};

int stonesAmountForProduct(String productId) =>
    kStonesAmountByProductId[productId] ?? 0;
