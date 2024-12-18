import static java.lang.System.err;
import static java.lang.System.exit;
import static java.lang.System.out;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Scanner;
import java.util.Set;

record Point(int x, int y) {
}

public class Main {
    private static final int EX_USAGE = 64;
    private static final Point[] directions = {
            new Point(-1, 0),
            new Point(0, 1),
            new Point(1, 0),
            new Point(0, -1)
    };

    public static void main(String[] args) throws FileNotFoundException {
        if (args.length != 1) {
            err.println("java 2024/day-06/Main.java <file>");
            exit(EX_USAGE);
        }

        try (Scanner scanner = new Scanner(new File(args[0]))) {
            List<String> lines = getLines(scanner);
            int maxRows = lines.size();
            int maxCols = lines.get(0).length();

            Point currentPoint = getCurrentPosition(lines);
            int visitedPoints = calculateGuardPoints(lines, maxRows, maxCols, currentPoint);
            out.printf("Part 1: %d\n", visitedPoints);

            int obstructionPlacementCount = 0;
            for (int i = 0; i < maxRows; i++) {
                String line = lines.get(i);
                for (int j = 0; j < maxCols; j++) {
                    char ch = line.charAt(j);

                    if (ch == '.' && !currentPoint.equals(new Point(i, j))) {
                        StringBuilder sb = new StringBuilder(line);
                        sb.setCharAt(j, '#');
                        lines.set(i, sb.toString());

                        if (solveCycle(lines, maxRows, maxCols, currentPoint))
                            obstructionPlacementCount++;

                        sb.setCharAt(j, '.');
                        lines.set(i, sb.toString());
                    }
                }
            }

            out.printf("Part 2: %d\n", obstructionPlacementCount);
        }
    }

    private static int calculateGuardPoints(List<String> lines, int maxRows, int maxCols, Point currentPoint) {
        int direction = 0;
        Set<Point> visitedPoints = new HashSet<>();

        while (true) {
            visitedPoints.add(currentPoint);
            int x = currentPoint.x() + directions[direction].x();
            int y = currentPoint.y() + directions[direction].y();

            if (!(0 <= x && x < maxRows && 0 <= y && y < maxCols))
                break;

            if (lines.get(x).charAt(y) == '.')
                currentPoint = new Point(x, y);
            else
                direction = (direction + 1) % 4;
        }
        return visitedPoints.size();
    }

    private static boolean solveCycle(List<String> lines, int maxRows, int maxCols, Point currentPoint) {
        int direction = 0;
        Set<List<Integer>> visitedPoints = new HashSet<>();

        while (true) {
            if (!visitedPoints.add(List.of(currentPoint.x(), currentPoint.y(),
                    direction)))
                return true;

            int x = currentPoint.x() + directions[direction].x();
            int y = currentPoint.y() + directions[direction].y();

            if (!(0 <= x && x < maxRows && 0 <= y && y < maxCols))
                return false;

            if (lines.get(x).charAt(y) == '.')
                currentPoint = new Point(x, y);
            else
                direction = (direction + 1) % 4;
        }
    }

    private static List<String> getLines(Scanner scanner) {
        List<String> lines = new ArrayList<>();

        while (scanner.hasNextLine())
            lines.add(scanner.nextLine());

        return lines;
    }

    private static Point getCurrentPosition(List<String> lines) {
        for (int i = 0; i < lines.size(); i++) {
            String line = lines.get(i);
            for (int j = 0; j < line.length(); j++) {
                char ch = line.charAt(j);

                if (ch == '^') {
                    lines.set(i, line.replace("^", "."));
                    return new Point(i, j);
                }
            }
        }

        return new Point(-1, -1);
    }
}
