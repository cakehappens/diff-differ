#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="${REPO_ROOT}/docs"
EXAMPLES_DIR="${DOCS_DIR}/examples"

function gen_k8s_manifests() {
  K8S_MANIFESTS_DIR="${EXAMPLES_DIR}/k8s-manifests"

  PODINFO_CHART_DIR="${K8S_MANIFESTS_DIR}/charts/podinfo"
  RENDERED_DIR_PREFIX="${K8S_MANIFESTS_DIR}/rendered-"
  INPUT_VALUES_DIR_PREFIX="${K8S_MANIFESTS_DIR}/input-values-"
  DIFF_FILE="${K8S_MANIFESTS_DIR}/diffs.patch"

  rm -f "${DIFF_FILE}"

  function helm_template() {
    comp_num="${1}"
    cluster_num="${2}"

    release_name="cluster-${cluster_num}"

    helm template \
      "${release_name}" "${PODINFO_CHART_DIR}" \
      --skip-tests \
      -f "${INPUT_VALUES_DIR_PREFIX}${comp_num}/${release_name}.yaml" \
        > "${RENDERED_DIR_PREFIX}${comp_num}/${release_name}.yaml"
  }

  for comp_num in $(seq 1 2); do
    output_dir="${RENDERED_DIR_PREFIX}${comp_num}"
    rm -rfd "${output_dir}"
    mkdir -p "${output_dir}"

    for num in $(seq 1 3); do
      helm_template "${comp_num}" "${num}"
    done
  done

  diff -u \
    "${RENDERED_DIR_PREFIX}1/" \
    "${RENDERED_DIR_PREFIX}2/" \
    | tee "${DIFF_FILE}"
}

gen_k8s_manifests
