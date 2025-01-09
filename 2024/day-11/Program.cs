using System.Numerics;

static BigInteger ComputeStoneCount(Dictionary<BigInteger, BigInteger> stones, int blinks)
{
    for (int i = 1; i <= blinks; i++)
    {
        Dictionary<BigInteger, BigInteger> newStones = [];

        foreach ((BigInteger stone, BigInteger count) in stones)
        {
            int digitCount = (int)BigInteger.Log10(stone) + 1;
            if (stone == 0) AddOrUpdate(newStones, 1, count);
            else if (digitCount % 2 == 0)
            {
                BigInteger half = BigInteger.Pow(10, digitCount / 2);
                AddOrUpdate(newStones, stone / half, count);
                AddOrUpdate(newStones, stone % half, count);
            }
            else
            {
                AddOrUpdate(newStones, stone * 2024, count);
            }
        }

        stones = newStones;
    }

    return (BigInteger)stones.Sum(x => (long)x.Value);
}

static void AddOrUpdate(Dictionary<BigInteger, BigInteger> stones, BigInteger key, BigInteger value)
{
    if (stones.ContainsKey(key))
    {
        stones[key] += value;
    }
    else
    {
        stones[key] = value;
    }
}

const int EX_USAGE = 64;

if (args.Length != 2)
{
    Console.Error.WriteLine("Usage: dotnet run 2024/day-11/Program.cs <file>");
    Environment.Exit(EX_USAGE);
}

Dictionary<BigInteger, BigInteger> stones = File
    .ReadAllText(args[1])
    .Split(" ")
    .Select(BigInteger.Parse)
    .GroupBy(x => x)
    .ToDictionary(g => g.Key, g => (BigInteger)g.Count());

BigInteger stoneCount = ComputeStoneCount(stones, 25);
Console.WriteLine($"Part 1: {stoneCount}");
stoneCount = ComputeStoneCount(stones, 75);
Console.WriteLine($"Part 2: {stoneCount}");
