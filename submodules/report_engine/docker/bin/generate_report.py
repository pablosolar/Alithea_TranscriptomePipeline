#!/usr/bin/env python3

import os
import argparse
import pandas as pd
from jinja2 import Environment, FileSystemLoader


def generate_html_table(df, table_id, num_visible=5):
    """Generate an expandable HTML table from a pandas DataFrame."""
    if df.empty:
        return "<p>No data available</p>"

    table_html = f"""
    <table id="{table_id}" class="expandable-table" border="1">
        <thead>
            <tr>
                {''.join(f'<th>{col}</th>' for col in df.columns)}
            </tr>
        </thead>
        <tbody>
    """

    # First num_visible rows (always visible)
    for _, row in df.iloc[:num_visible].iterrows():
        table_html += "<tr>" + "".join(f"<td>{value}</td>" for value in row) + "</tr>\n"

    # Hidden rows (Expandable)
    if len(df) > num_visible:
        table_html += f'<tbody id="{table_id}_hidden" style="display:none;">\n'
        for _, row in df.iloc[num_visible:].iterrows():
            table_html += "<tr>" + "".join(f"<td>{value}</td>" for value in row) + "</tr>\n"
        table_html += "</tbody>\n"

        # Expand/Collapse button
        table_html += f'''
        </tbody>
        </table>
        <button onclick="toggleRows('{table_id}')">Expand</button>
        <script>
            function toggleRows(tableId) {{
                var hiddenRows = document.getElementById(tableId + "_hidden");
                var button = document.querySelector("#" + tableId + " + button");
                if (hiddenRows.style.display === "none") {{
                    hiddenRows.style.display = "table-row-group";
                    button.innerText = "Collapse";
                }} else {{
                    hiddenRows.style.display = "none";
                    button.innerText = "Expand";
                }}
            }}
        </script>
        '''

    return table_html


def safe_read_csv(filepath):
    """Safely read a CSV file and return either its HTML representation or None."""
    if filepath and os.path.exists(filepath) and os.path.getsize(filepath) > 0:
        return pd.read_csv(filepath, sep="\t").to_html(index=False)
    return None


def safe_generate_html_table(filepath, table_id):
    """Safely generate an HTML table from a CSV file."""
    if filepath and os.path.exists(filepath) and os.path.getsize(filepath) > 0:
        return generate_html_table(pd.read_csv(filepath, sep="\t").head(100), table_id)
    return None


def safe_path(filepath):
    """Return absolute path if the file exists; otherwise, return None."""
    return os.path.abspath(filepath) if filepath and os.path.exists(filepath) else None


def generate_report(args):
    """ Generates the HTML report """

    # Required Inputs
    index_info = safe_path(args.index_info) or "Index info not available"
    transcriptome_counts = safe_read_csv(args.transcriptome_counts) or "<p>No transcriptome count data available</p>"

    # Boxplot (only included if both SE and PE exist)
    boxplot = safe_path(args.boxplot) if args.se_metadata and args.pe_metadata else None

    # Single-End (SE) Results
    se_metadata = safe_read_csv(args.se_metadata)
    se_lrt_results = safe_generate_html_table(args.se_lrt_results, "se_lrt_results")
    se_wald_results = safe_generate_html_table(args.se_wald_results, "se_wald_results")
    se_pca = safe_path(args.se_pca)
    se_heatmap = safe_path(args.se_heatmap)
    se_transcript_heatmap = safe_path(args.se_transcript_heatmap)
    se_bootstrap = safe_path(args.se_bootstrap)

    # Paired-End (PE) Results
    pe_metadata = safe_read_csv(args.pe_metadata)
    pe_lrt_results = safe_generate_html_table(args.pe_lrt_results, "pe_lrt_results")
    pe_wald_results = safe_generate_html_table(args.pe_wald_results, "pe_wald_results")
    pe_pca = safe_path(args.pe_pca)
    pe_heatmap = safe_path(args.pe_heatmap)
    pe_transcript_heatmap = safe_path(args.pe_transcript_heatmap)
    pe_bootstrap = safe_path(args.pe_bootstrap)

    # Load Jinja2 template
    env = Environment(loader=FileSystemLoader('/bin'))
    template = env.get_template("report_template.html")

    # Render HTML
    html_output = template.render(
        index_info=index_info,
        transcriptome_counts=transcriptome_counts,
        boxplot=boxplot,

        # SE Results
        se_metadata=se_metadata,
        se_lrt_results=se_lrt_results,
        se_wald_results=se_wald_results,
        se_pca=se_pca,
        se_heatmap=se_heatmap,
        se_transcript_heatmap=se_transcript_heatmap,
        se_bootstrap=se_bootstrap,

        # PE Results
        pe_metadata=pe_metadata,
        pe_lrt_results=pe_lrt_results,
        pe_wald_results=pe_wald_results,
        pe_pca=pe_pca,
        pe_heatmap=pe_heatmap,
        pe_transcript_heatmap=pe_transcript_heatmap,
        pe_bootstrap=pe_bootstrap
    )

    # Save to file
    with open("transcriptome_pipeline_report.html", "w") as f:
        f.write(html_output)

    print(f"Report generated: transcriptome_pipeline_report.html")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate HTML report for transcriptome analysis")
    parser.add_argument("--index-info", required=True, type=str, help="Index information file")
    parser.add_argument("--transcriptome-counts", required=True, help="Transcriptome count matrix file")
    parser.add_argument("--boxplot", help="Path to transcriptome detection boxplot")

    # SE Inputs
    parser.add_argument("--se-metadata", type=str, help="SE Metadata file for DEA")
    parser.add_argument("--se-lrt-results", type=str, help="SE Sleuth LRT results file")
    parser.add_argument("--se-wald-results", type=str, help="SE Sleuth Wald results file")
    parser.add_argument("--se-pca", type=str, help="SE PCA plot image")
    parser.add_argument("--se-heatmap", type=str, help="SE Sample heatmap image")
    parser.add_argument("--se-transcript-heatmap", type=str, help="SE Transcriptome expression heatmap image")
    parser.add_argument("--se-bootstrap", type=str, help="SE Bootstrap confidence plot")

    # PE Inputs
    parser.add_argument("--pe-metadata", type=str, help="PE Metadata file for DEA")
    parser.add_argument("--pe-lrt-results", type=str, help="PE Sleuth LRT results file")
    parser.add_argument("--pe-wald-results", type=str, help="PE Sleuth Wald results file")
    parser.add_argument("--pe-pca", type=str, help="PE PCA plot image")
    parser.add_argument("--pe-heatmap", type=str, help="PE Sample heatmap image")
    parser.add_argument("--pe-transcript-heatmap", type=str, help="PE Transcriptome expression heatmap image")
    parser.add_argument("--pe-bootstrap", type=str, help="PE Bootstrap confidence plot")

    args = parser.parse_args()
    generate_report(args)