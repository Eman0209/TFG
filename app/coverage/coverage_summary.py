import os

def normalize_path(path):
    return path.replace('\\', '/')

def parse_lcov(file_path, test_type, include_prefix, output_filename):
    coverage_data = {}
    current_file = None
    include_prefix = normalize_path(os.path.abspath(include_prefix))

    try:
        with open(file_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line.startswith('SF:'):
                    raw_path = line[3:]
                    norm_path = normalize_path(os.path.abspath(raw_path))
                    current_file = norm_path
                    if current_file.startswith(include_prefix):
                        if current_file not in coverage_data:
                            coverage_data[current_file] = {'total': 0, 'covered': 0}
                elif line.startswith('DA:') and current_file and current_file.startswith(include_prefix):
                    parts = line[3:].split(',')
                    hit_count = int(parts[1])
                    coverage_data[current_file]['total'] += 1
                    if hit_count > 0:
                        coverage_data[current_file]['covered'] += 1
    except FileNotFoundError:
        print(f'[!] Coverage file not found: {file_path}')
        return

    if not coverage_data:
        print(f'[!] No matching files for {test_type} in path: {include_prefix}')
        return

    with open(output_filename, 'w') as out:
        out.write(f'Coverage report for {test_type} tests\n')
        out.write('-' * 60 + '\n')

        for file, data in coverage_data.items():
            total = data['total']
            covered = data['covered']
            coverage_percent = (covered / total * 100) if total > 0 else 0
            out.write(f'File: {file}\n')
            out.write(f'  Total lines: {total}\n')
            out.write(f'  Covered lines: {covered}\n')
            out.write(f'  Coverage: {coverage_percent:.2f}%\n\n')
        
        # Overall summary
        out.write('-' * 60 + '\n')
        total_lines = sum(d['total'] for d in coverage_data.values())
        covered_lines = sum(d['covered'] for d in coverage_data.values())
        overall_percent = (covered_lines / total_lines * 100) if total_lines > 0 else 0
        out.write(f'Total lines: {total_lines}\n')
        out.write(f'Covered lines: {covered_lines}\n')
        out.write(f'Overall coverage: {overall_percent:.2f}%\n')

    print(f'[✓] {test_type.capitalize()} test coverage written to: {output_filename}')
    return {
        'type': test_type,
        'total': total_lines,
        'covered': covered_lines
    }


def write_combined_summary(summary_list, output_file):
    total_all = sum(s['total'] for s in summary_list)
    covered_all = sum(s['covered'] for s in summary_list)
    overall_percent = (covered_all / total_all * 100) if total_all > 0 else 0

    with open(output_file, 'w') as out:
        out.write('Overall Combined Coverage Summary\n')
        out.write('-' * 40 + '\n')
        for s in summary_list:
            percent = (s['covered'] / s['total'] * 100) if s['total'] > 0 else 0
            out.write(f'Test type: {s["type"]}\n')
            out.write(f'  Total lines: {s["total"]}\n')
            out.write(f'  Covered lines: {s["covered"]}\n')
            out.write(f'  Coverage: {percent:.2f}%\n\n')
        out.write('-' * 40 + '\n')
        out.write(f'Combined Total:\n')
        out.write(f'  Total lines: {total_all}\n')
        out.write(f'  Covered lines: {covered_all}\n')
        out.write(f'  Overall coverage: {overall_percent:.2f}%\n')

    print(f'[✓] Combined coverage summary written to: {output_file}')


if __name__ == '__main__':
    config = [
        {
            'test_type': 'unit',
            'lcov_path': './unit/lcov.info',
            'include_prefix': 'lib/data/datasources/',
            'output': 'coverage_report_unit.txt',
        },
        {
            'test_type': 'widget',
            'lcov_path': './widget/lcov.info',
            'include_prefix': 'lib/presentation/screens/',
            'output': 'coverage_report_widget.txt',
        }
    ]

    summaries = []
    for entry in config:
        result = parse_lcov(
            file_path=entry['lcov_path'],
            test_type=entry['test_type'],
            include_prefix=entry['include_prefix'],
            output_filename=entry['output']
        )
        if result:
            summaries.append(result)

    # Write combined summary
    write_combined_summary(summaries, 'coverage_report_total.txt')