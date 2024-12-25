#ifdef __unix__
#include <sysexits.h>
#else
#define EX_USAGE 64
#endif

#include <algorithm>
#include <fstream>
#include <iostream>
#include <list>
#include <unordered_map>
#include <unordered_set>
#include <vector>

using std::cerr;
using std::cout;
using std::find;
using std::getline;
using std::hash;
using std::ifstream;
using std::list;
using std::make_pair;
using std::pair;
using std::string;
using std::unordered_map;
using std::unordered_set;
using std::vector;

typedef pair<int, int> Coordinate;
typedef list<Coordinate> Coordinates;
typedef vector<vector<char>> Map;
typedef unordered_map<char, Coordinates> Frequencies;

struct PairHash {
    template <typename T1, typename T2>
    size_t operator()(const pair<T1, T2> &pair) const {
        return hash<T1>()(pair.first) ^ (hash<T2>()(pair.second) << 1);
    }
};

void read_chars(ifstream &file, Map &map) {
    string line;
    while (getline(file, line)) map.push_back(vector(line.begin(), line.end()));
}

void add_unique_frequencies(const Map &map, Frequencies &frequencies) {
    for (const vector<char> &row : map) {
        for (const char frequency : row) {
            if (frequency == '.') continue;

            int row_index = find(map.begin(), map.end(), row) - map.begin();
            int col_index =
                find(row.begin(), row.end(), frequency) - row.begin();
            frequencies[frequency].push_back(make_pair(row_index, col_index));
        }
    }
}

inline bool inbound(const Coordinate &antinode, int max_rows, int max_cols) {
    return (0 <= antinode.first && antinode.first < max_rows) &&
           (0 <= antinode.second && antinode.second < max_cols);
}

bool add_antinode(Coordinate antinode, int max_rows, int max_cols,
                  unordered_set<Coordinate, PairHash> &antinodes) {
    if (!inbound(antinode, max_rows, max_cols)) return false;

    antinodes.insert(antinode);
    return true;
}

void create_antinode(Coordinate current_coords, Coordinate coords,
                     Coordinate distance,
                     unordered_set<Coordinate, PairHash> &antinodes,
                     int max_rows, int max_cols, bool part2) {
    Coordinate antinode1 = make_pair(coords.first - distance.first,
                                     coords.second - distance.second);
    Coordinate antinode2 = make_pair(current_coords.first + distance.first,
                                     current_coords.second + distance.second);
    bool added_antinode1 =
        add_antinode(antinode1, max_rows, max_cols, antinodes);
    bool added_antinode2 =
        add_antinode(antinode2, max_rows, max_cols, antinodes);

    if (!added_antinode1 && !added_antinode2) return;

    if (part2)
        create_antinode(antinode2, antinode1, distance, antinodes, max_rows,
                        max_cols, part2);
}

int find_antinode_count(Map map, bool part2) {
    Frequencies frequencies;
    add_unique_frequencies(map, frequencies);

    unordered_set<Coordinate, PairHash> antinodes;

    int max_rows = map.size();
    int max_cols = map[0].size();

    for (auto &[frequency, coords_list] : frequencies) {
        if (part2 && coords_list.size() > 2) {
            for (const Coordinate &coords : coords_list)
                antinodes.insert(coords);
        }

        while (!coords_list.empty()) {
            Coordinate current_coords = coords_list.front();
            auto [current_row, current_col] = current_coords;
            coords_list.pop_front();

            map[current_row][current_col] = '*';

            for (Coordinate coords : coords_list) {
                auto [row, col] = coords;
                map[row][col] = '*';
                Coordinate distance =
                    make_pair(current_row - row, current_col - col);

                create_antinode(current_coords, coords, distance, antinodes,
                                max_rows, max_cols, part2);
                map[row][col] = frequency;
            }

            map[current_row][current_col] = frequency;
        }
    }

    return antinodes.size();
}

int main(int argc, char **argv) {
    if (argc != 2) {
        cerr << "Usage: " << argv[0] << " <file>\n";
        return EX_USAGE;
    }

    ifstream file(argv[1]);

    vector<vector<char>> map;
    read_chars(file, map);

    int antinode_count = find_antinode_count(map, false);
    cout << "Part 1 Result: " << antinode_count << "\n";

    antinode_count = find_antinode_count(map, true);
    cout << "Part 2 Result: " << antinode_count << "\n";

    return EXIT_SUCCESS;
}
