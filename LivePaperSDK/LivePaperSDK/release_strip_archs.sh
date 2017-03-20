LIVE_PAPER_FRAMEWORK="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/LivePaperSDK.framework"
LIVE_PAPER_BINARY="${LIVE_PAPER_FRAMEWORK}/LivePaperSDK"
archs=$(lipo -info "$LIVE_PAPER_BINARY" | rev | cut -d ':' -f1 | rev)

for arch in $archs; do
if [[ "$VALID_ARCHS" != *"$arch"* ]]; then
lipo -remove "$arch" -output "$LIVE_PAPER_BINARY" "$LIVE_PAPER_BINARY" || exit 1
echo "Removed $arch from $LIVE_PAPER_BINARY"
fi
done

rm -f "$LIVE_PAPER_FRAMEWORK/strip-framework.sh"
