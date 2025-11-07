/**
 *  Introduces component library styles on demand.
 * https://github.com/anncwb/vite-plugin-style-import
 *
 * 注意：由于 unplugin-vue-components 已经可以自动导入组件和样式，
 * 此插件可能会与 unplugin-vue-components 冲突，导致导入路径错误。
 * 如果遇到导入错误，可以禁用此插件。
 */
import styleImport, { VantResolve } from 'vite-plugin-style-import'

export function configStyleImportPlugin(isBuild: boolean) {
	// 暂时禁用此插件，因为 unplugin-vue-components 已经处理了样式导入
	// 如果确实需要此插件，可以取消下面的注释
	return null

	// return styleImport({
	// 	resolves: [VantResolve()]
	// })
}
