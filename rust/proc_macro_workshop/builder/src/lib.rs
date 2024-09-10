use quote::{format_ident, quote};
use proc_macro::TokenStream;
use syn::{Data, DataStruct, DeriveInput, Fields, parse_macro_input};

#[proc_macro_derive(Builder, attributes(builder))]
pub fn derive(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);

    // eprintln!("AST: {:#?}", input);

    let fields = match &input.data {
        Data::Struct(DataStruct {
            fields: Fields::Named(it),
            ..
        }) => &it.named,
        _ => unimplemented!(),
    };

    let field_names = fields.iter().map(|f| &f.ident);    

    let builder_fields = fields.iter().map(|f| {
        let name = &f.ident;
        let ty = &f.ty;

        if ty_inner_type("Option", ty).is_some() || builder_of(&f).is_some() {
            quote! { #name: #ty }
        } else {
            quote! { #name: ::std::option::Option<#ty> }
        }
        
    });

    let builder_defaults = fields.iter().map(|f| {
        let name = &f.ident;
        if builder_of(f).is_some() {
            quote! { #name: ::std::vec::Vec::new() }
        } else {
            quote! { #name: ::std::option::Option::None }
        }
    });

    let setters = fields.iter().map(|f| {
        let name = &f.ident;
        let ty = &f.ty;

        let (arg_type, value) = if let Some(inner_ty) = ty_inner_type("Option", ty) {
            (inner_ty, quote! { Some(#name) })
        } else if builder_of(&f).is_some() {
            (ty, quote! { #name })
        } else {
            (ty, quote! { Some(#name) })
        };

        let set_method = quote! {
            pub fn #name(&mut self, #name: #arg_type) -> &mut Self {
                self.#name = #value;
                self
            }
        };

        match extend_method(&f) {
            None => set_method.into(),
            Some((true, extend_method)) => extend_method,
            Some((false, extend_method)) => {
                let expr = quote! {
                    #set_method
                    #extend_method
                };
                expr.into()
            }
        }
    });

    let validators = fields.iter().map(|f| {
        let name = &f.ident;
        if ty_inner_type("Option", &f.ty).is_some() || builder_of(f).is_some() {
            quote! {
                let #name = self.#name.clone();
            }
        } else {
            quote! {
                let #name = self.#name.take().ok_or_else(|| format!("The field {} has not been set", stringify!(#name)))?;
            }
        }
    });

    let name = input.ident;

    let builder_name = format_ident!("{}Builder", name);

    let expanded = quote! {
        pub struct #builder_name {
            #(#builder_fields,)*
        }

        impl #builder_name {
            #(#setters)*

            pub fn build(&mut self) -> ::std::result::Result<#name, ::std::boxed::Box<dyn ::std::error::Error>> {
                #(#validators)*
                ::std::result::Result::Ok(#name {
                    #(#field_names,)*
                })
            }
        }

        impl #name {
            pub fn builder() -> #builder_name {
                #builder_name {
                    #(#builder_defaults,)*
                }
            }
        }
    };

    TokenStream::from(expanded)
}

fn builder_of(f: &syn::Field) -> Option<&syn::Attribute> {
    for attr in &f.attrs {
        if attr.path.segments.len() == 1 && attr.path.segments[0].ident == "builder" {
            return Some(attr);
        }
    }

    None
}

fn extend_method(f: &syn::Field) -> Option<(bool, proc_macro2::TokenStream)> {
    let name = f.ident.as_ref().unwrap();
    let g = builder_of(f)?;

    fn mk_err<T: quote::ToTokens>(t: T) -> Option<(bool, proc_macro2::TokenStream)> {
        Some((
            false, 
            syn::Error::new_spanned(t, "expected `builder(each = \"...\")`").to_compile_error(),
        ))
    }

    let meta = match g.parse_meta() {
        Ok(syn::Meta::List(mut nvs)) => {
            assert_eq!(nvs.path.segments[0].ident, "builder");
            if nvs.nested.len() != 1 {
                return mk_err(nvs);
            }

            match nvs.nested.pop().unwrap().into_value() {
                syn::NestedMeta::Meta(syn::Meta::NameValue(nv)) =>  {
                    if !nv.path.is_ident("each") {
                        return mk_err(nv);
                    }
                    nv
                }
                meta => {
                    return mk_err(meta);
                }
            }
        }
        Ok(meta) => {
            return mk_err(meta);
        }
        Err(e) => {
            return Some((false, e.to_compile_error()));
        }
    };

    match meta.lit {
        syn::Lit::Str(s) => {
            let arg = syn::Ident::new(&s.value(), s.span());
            let inner_ty = ty_inner_type("Vec", &f.ty).unwrap();
            let method = quote! {
                pub fn #arg(&mut self, #arg: #inner_ty) -> &mut Self {
                    self.#name.push(#arg);
                    self
                }
            };

            Some((&arg == name, method))
        }
        lit => panic!("expected string, found {:?}", lit)
    }
}

fn ty_inner_type<'a>(wrapper: &str, ty: &'a syn::Type) -> Option<&'a syn::Type> {
    if let syn::Type::Path(ref p) = ty {
        if p.path.segments.len() != 1 || p.path.segments[0].ident != wrapper {
            return None;
        }

        match p.path.segments[0].arguments {
            syn::PathArguments::AngleBracketed(ref inner_ty) => {
                match inner_ty.args[0] {
                    syn::GenericArgument::Type(ref t) => return Some(t),
                    _ => (),
                }
            }
            _ => (),
        }
    }

    None
}