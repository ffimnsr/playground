use yew::prelude::*;

#[function_component(Footer)]
pub fn footer() -> Html {
    let socials = html!{
        <div class="flex justify-center space-x-6 md:order-2">
            <a href="https://t.me/JobsSesame" target="_blank" class="text-gray-900 hover:text-gray-500">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" stroke="currentColor" class="size-6">
                    <path d="M446.7 98.6l-67.6 318.8c-5.1 22.5-18.4 28.1-37.3 17.5l-103-75.9-49.7 47.8c-5.5 5.5-10.1 10.1-20.7 10.1l7.4-104.9 190.9-172.5c8.3-7.4-1.8-11.5-12.9-4.1L117.8 284 16.2 252.2c-22.1-6.9-22.5-22.1 4.6-32.7L418.2 66.4c18.4-6.9 34.5 4.1 28.5 32.2z"/>
                </svg>
            </a>
            <a href="https://www.linkedin.com/company/jobs-se-same" target="_blank" class="text-gray-900 hover:text-gray-500">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" stroke="currentColor" class="size-6">
                    <path d="M416 32H31.9C14.3 32 0 46.5 0 64.3v383.4C0 465.5 14.3 480 31.9 480H416c17.6 0 32-14.5 32-32.3V64.3c0-17.8-14.4-32.3-32-32.3zM135.4 416H69V202.2h66.5V416zm-33.2-243c-21.3 0-38.5-17.3-38.5-38.5S80.9 96 102.2 96c21.2 0 38.5 17.3 38.5 38.5 0 21.3-17.2 38.5-38.5 38.5zm282.1 243h-66.4V312c0-24.8-.5-56.7-34.5-56.7-34.6 0-39.9 27-39.9 54.9V416h-66.4V202.2h63.7v29.2h.9c8.9-16.8 30.6-34.5 62.9-34.5 67.2 0 79.7 44.3 79.7 101.9V416z"/>
                </svg>
            </a>
        </div>
    };
    html! {
        <footer class="bg-white dark:invert inset-x-0 bottom-0">
            <div class="mx-auto max-w-7xl px-6 py-4 md:flex md:items-center md:justify-between lg:px-8">
                {socials}
                <div class="mt-8 md:order-1 md:mt-0">
                    <p class="text-center text-xs leading-5 text-gray-500">
                        {"© 2024 Jobs gSe-same. All rights reserved."}
                    </p>
                </div>
            </div>
        </footer>
    }
}