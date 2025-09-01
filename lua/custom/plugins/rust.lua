---@type LazyPluginSpec
--- Note: default workspace symbol search is for types in the workspace. Use
--- `foo#` to search for all symbol types, use `foo*` to search in
--- dependencies.
return {
  'mrcjkb/rustaceanvim',
  version = '^6', -- Recommended
  lazy = false, -- This plugin is already lazy
  keys = {
    { 'J', '<cmd>RustLsp joinLines<cr>', ft = 'rust', desc = 'Rust join lines', mode = 'n' },
    { 'J', "<cmd>'<,'>RustLsp joinLines<cr>", ft = 'rust', desc = 'Rust join lines (visual)', mode = 'x' },
    { 'K', '<cmd>RustLsp hover actions<cr>', ft = 'rust', desc = 'Rust hover actions', mode = 'n' },
    { 'K', "<cmd>'<,'>RustLsp hover range<cr>", ft = 'rust', desc = 'Rust hover range (visual)', mode = 'x' },
    { 'gra', '<cmd>RustLsp codeAction<cr>', ft = 'rust', desc = 'Rust code action', mode = 'n' },
    { '<leader>cr', '<cmd>RustLsp run<cr>', ft = 'rust', desc = 'Rust run', mode = 'n' },
    { '<leader>cR', '<cmd>RustLsp runnables<cr>', ft = 'rust', desc = 'Rust runnables', mode = 'n' },
    { '<leader>ct', '<cmd>RustLsp test<cr>', ft = 'rust', desc = 'Rust test', mode = 'n' },
    { '<leader>cT', '<cmd>RustLsp testables<cr>', ft = 'rust', desc = 'Rust testables', mode = 'n' },
    { '<leader>cd', '<cmd>RustLsp debug<cr>', ft = 'rust', desc = 'Rust debug', mode = 'n' },
    { '<leader>cD', '<cmd>RustLsp debuggables<cr>', ft = 'rust', desc = 'Rust debuggables', mode = 'n' },
    { '<leader>cm', '<cmd>RustLsp expandMacro<cr>', ft = 'rust', desc = 'Rust expand macro', mode = 'n' },
    { '<leader>cJ', '<cmd>RustLsp moveItem down<cr>', ft = 'rust', desc = 'Rust move item down', mode = 'n' },
    { '<leader>cK', '<cmd>RustLsp moveItem up<cr>', ft = 'rust', desc = 'Rust move item up', mode = 'n' },
    { '<leader>cE', '<cmd>RustLsp explainError<cr>', ft = 'rust', desc = 'Rust explain error', mode = 'n' },
    { '<leader>cl', '<cmd>RustLsp relatedDiagnostics<cr>', ft = 'rust', desc = 'Rust related diagnostics', mode = 'n' },
    { '<leader>cg', '<cmd>RustLsp renderDiagnostic<cr>', ft = 'rust', desc = 'Rust render diagnostic', mode = 'n' },
    { '<leader>cO', '<cmd>RustLsp openCargo<cr>', ft = 'rust', desc = 'Rust open Cargo.toml', mode = 'n' },
    { '<leader>co', '<cmd>RustLsp openDocs<cr>', ft = 'rust', desc = 'Rust open docs.rs', mode = 'n' },
    { '<leader>cP', '<cmd>RustLsp parentModule<cr>', ft = 'rust', desc = 'Rust parent module', mode = 'n' },
    { '<leader>cF', '<cmd>RustLsp flyCheck run<cr>', ft = 'rust', desc = 'Rust fly check', mode = 'n' },
    { '<leader>cL', '<cmd>RustLsp logFile<cr>', ft = 'rust', desc = 'Rust log file', mode = 'n' },
  },
  init = function()
    vim.g.rustaceanvim = {
      tools = { test_executor = 'background', crate_test_executor = 'background' },
      server = {
        default_settings = {
          -- https://rust-analyzer.github.io/book/configuration
          ['rust-analyzer'] = {
            assist = {
              preferSelf = true,
            },
            check = {
              command = 'clippy',
              extraArgs = { '--no-deps' },
              ignore = nil,
            },
            completion = {
              fullFunctionSignatures = {
                enable = true,
              },
              termSearch = {
                enable = true,
              },
              snippets = {
                custom = {
                  ['context'] = {
                    postfix = 'ctx',
                    body = { '${receiver}.context("$0")' },
                    description = 'Wrap Err and add context',
                    requires = 'color_eyre::eyre::Context',
                    scope = 'expr',
                  },
                  -- Below were the defaults listed by https://github.com/rust-lang/rust-analyzer/blob/master/crates/ide-completion/src/snippet.rs#L5 at time of writing
                  ['Arc::new'] = {
                    postfix = 'arc',
                    body = 'Arc::new(${receiver})',
                    requires = 'std::sync::Arc',
                    description = 'Put the expression into an `Arc`',
                    scope = 'expr',
                  },
                  ['Rc::new'] = {
                    postfix = 'rc',
                    body = 'Rc::new(${receiver})',
                    requires = 'std::rc::Rc',
                    description = 'Put the expression into an `Rc`',
                    scope = 'expr',
                  },
                  ['Box::pin'] = {
                    postfix = 'pinbox',
                    body = 'Box::pin(${receiver})',
                    requires = 'std::boxed::Box',
                    description = 'Put the expression into a pinned `Box`',
                    scope = 'expr',
                  },
                  ['Ok'] = {
                    postfix = 'ok',
                    body = 'Ok(${receiver})',
                    description = 'Wrap the expression in a `Result::Ok`',
                    scope = 'expr',
                  },
                  ['Err'] = {
                    postfix = 'err',
                    body = 'Err(${receiver})',
                    description = 'Wrap the expression in a `Result::Err`',
                    scope = 'expr',
                  },
                  ['Some'] = {
                    postfix = 'some',
                    body = 'Some(${receiver})',
                    description = 'Wrap the expression in an `Option::Some`',
                    scope = 'expr',
                  },
                },
              },
            },
            diagnostics = {
              styleLints = {
                enable = true,
              },
            },
            highlightRelated = {
              -- These were marked as enabled by default, but needed to manually enable for them to work
              branchExitPoints = { enable = true },
              breakPoints = { enable = true },
              closureCaptures = { enable = true },
              exitPoints = { enable = true },
              references = { enable = true },
              yieldPoints = { enable = true },
            },
            hover = {
              show = {
                traitAssocItems = 5,
              },
            },
            -- Inlay hints can be quite noisy, but useful for
            -- debugging/understanding, so recommend using the toggle shortcut
            inlayHints = {
              bindingModeHints = { enable = true },
              closureCaptureHints = { enable = true },
              closureReturnTypeHints = { enable = 'with_block' },
              expressionAdjustmentHints = { enable = 'reborrow', disableReborrows = true },
              genericParameterHints = {
                lifetime = { enable = true },
                type = { enable = true },
              },
              implicitDrops = { enable = true },
              implicitSizedBoundHints = { enable = true },
              lifetimeElisionHints = { enable = 'skip_trivial', useParameterNames = true },
              rangeExclusiveHints = { enable = true },
              typeHints = {
                enable = true,
                -- Already have the closure return type annotated, so it's
                -- redundant to show it for a variable declaration as well
                hideClosureInitialization = true,
              },
              lens = {
                references = {
                  adt = { enable = true },
                  enumVariant = { enable = true },
                  method = { enable = true },
                  trait = { enable = true },
                },
              },
              -- signatureInfo = { documentation = { enable = true } },
              -- This will only have an effect after the "format on type"
              -- feature of nvim is available
              typing = { triggerChars = '=.{(<>' },
            },
          },
        },
      },
    }
  end,
}
