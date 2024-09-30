use yew::prelude::*;

#[derive(Clone, Debug, PartialEq)]
pub struct Theme {
    pub is_dark: bool,
}

pub type ThemeContext = UseStateHandle<Theme>;

#[derive(Debug, PartialEq, Properties)]
pub struct ThemeProviderProps {
    #[prop_or_default]
    pub children: Html,
}

#[function_component]
pub fn ThemeProvider(props: &ThemeProviderProps) -> Html {
    let theme = use_state(|| Theme {
        is_dark: false,
    });

    html! {
        <ContextProvider<ThemeContext> context={theme}>
            {props.children.clone()}
        </ContextProvider<ThemeContext>>
    }
}