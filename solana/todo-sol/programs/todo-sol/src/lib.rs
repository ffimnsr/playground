use anchor_lang::prelude::*;

declare_id!("3ibA1xfXF5otPPpL94eoqrSDwVaYrQRz36zAQqtbAzL5");

#[program]
pub mod todo_sol {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        let user_profile = &mut ctx.accounts.user_profile;
        user_profile.bump = ctx.bumps.user_profile;
        user_profile.last_todo = 0;
        user_profile.todo_count = 0;

        Ok(())
    }

    pub fn add_todo(ctx: Context<AddTodo>, content: String) -> Result<()> {
        let todo_account = &mut ctx.accounts.todo_account;
        let user_profile = &mut ctx.accounts.user_profile;
        require!(content.as_bytes().len() < 200, TodoError::ContentTooLong);

        todo_account.author = ctx.accounts.authority.key();
        todo_account.bump = ctx.bumps.todo_account;
        todo_account.idx = user_profile.last_todo;
        todo_account.content = content;
        todo_account.marked = false;

        user_profile.last_todo = user_profile.last_todo.checked_add(1).unwrap();
        user_profile.todo_count = user_profile.todo_count.checked_add(1).unwrap();
        Ok(())
    }

    pub fn mark_todo(ctx: Context<MarkTodo>, todo_idx: u8) -> Result<()> {
        let todo_account = &mut ctx.accounts.todo_account;
        require!(!todo_account.marked, TodoError::AlreadyMarked);
        require_gte!(todo_idx, 0, TodoError::NotAllowed);

        todo_account.marked = true;
        Ok(())
    }

    pub fn unmark_todo(ctx: Context<UnmarkTodo>, todo_idx: u8) -> Result<()> {
        let todo_account = &mut ctx.accounts.todo_account;
        require!(todo_account.marked, TodoError::AlreadyUnmarked);
        require_gte!(todo_idx, 0, TodoError::NotAllowed);

        todo_account.marked = false;
        Ok(())
    }

    pub fn remove_todo(ctx: Context<RemoveTodo>, todo_idx: u8) -> Result<()> {
        let user_profile = &mut ctx.accounts.user_profile;
        require_gte!(todo_idx, 0, TodoError::NotAllowed);

        user_profile.todo_count = user_profile.todo_count.checked_sub(1).unwrap();
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(
        init,
        seeds = [USER_TAG, authority.key().as_ref()],
        bump,
        payer = authority,
        space = 8 + std::mem::size_of::<UserProfile>(),
    )]
    pub user_profile: Account<'info, UserProfile>,

    #[account(mut)]
    pub authority: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct AddTodo<'info> {
    #[account(
        mut,
        seeds = [USER_TAG, authority.key().as_ref()],
        bump,
    )]
    pub user_profile: Account<'info, UserProfile>,

    #[account(
        init,
        seeds = [TODO_TAG, authority.key().as_ref(), &[user_profile.last_todo as u8]],
        bump,
        payer = authority,
        space = 8 + std::mem::size_of::<TodoAccount>(),
    )]
    pub todo_account: Account<'info, TodoAccount>,

    #[account(mut)]
    pub authority: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
#[instruction(todo_idx: u8)]
pub struct MarkTodo<'info> {
    #[account(
        mut,
        seeds = [USER_TAG, authority.key().as_ref()],
        bump = user_profile.bump,
    )]
    pub user_profile: Account<'info, UserProfile>,

    #[account(
        mut,
        seeds = [TODO_TAG, authority.key().as_ref(), &[todo_idx]],
        bump = todo_account.bump,
    )]
    pub todo_account: Account<'info, TodoAccount>,

    #[account(mut)]
    pub authority: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
#[instruction(todo_idx: u8)]
pub struct UnmarkTodo<'info> {
    #[account(
        mut,
        seeds = [USER_TAG, authority.key().as_ref()],
        bump = user_profile.bump,
    )]
    pub user_profile: Account<'info, UserProfile>,

    #[account(
        mut,
        seeds = [TODO_TAG, authority.key().as_ref(), &[todo_idx]],
        bump = todo_account.bump,
    )]
    pub todo_account: Account<'info, TodoAccount>,

    #[account(mut)]
    pub authority: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
#[instruction(todo_idx: u8)]
pub struct RemoveTodo<'info> {
    #[account(
        mut,
        seeds = [USER_TAG, authority.key().as_ref()],
        bump = user_profile.bump,
    )]
    pub user_profile: Account<'info, UserProfile>,

    #[account(
        mut,
        seeds = [TODO_TAG, authority.key().as_ref(), &[todo_idx]],
        bump = todo_account.bump,
    )]
    pub todo_account: Account<'info, TodoAccount>,

    #[account(mut)]
    pub authority: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[account]
pub struct UserProfile {
    pub bump: u8,
    pub last_todo: u8,
    pub todo_count: u8,
}

#[account]
pub struct TodoAccount {
    pub author: Pubkey,
    pub bump: u8,
    pub idx: u8,
    pub content: String,
    pub marked: bool,
}

#[constant]
pub const USER_TAG: &[u8] = b"USER_STATE";

#[constant]
pub const TODO_TAG: &[u8] = b"TODO_STATE";

#[error_code]
pub enum TodoError {
    #[msg("You are not authorized to perform this action.")]
    Unauthorized,
    #[msg("The operation is not allowed.")]
    NotAllowed,
    #[msg("Math overflow.")]
    MathOverflow,
    #[msg("Content is too long.")]
    ContentTooLong,
    #[msg("The todo is already marked.")]
    AlreadyMarked,
    #[msg("The todo is already unmarked.")]
    AlreadyUnmarked,
}
