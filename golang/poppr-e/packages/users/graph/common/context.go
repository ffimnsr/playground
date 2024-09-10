package common

import (
	"context"
	"net/http"

	"gorm.io/gorm"
)

type CustomContext struct {
	Database *gorm.DB
}

type key string

var customCtxKey key = "CUSTOM_CONTEXT"

func CreateContext(args *CustomContext, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		customCtx := &CustomContext{
			Database: args.Database,
		}
		ctx := r.WithContext(context.WithValue(r.Context(), customCtxKey, customCtx))
		next.ServeHTTP(w, ctx)
	})
}

func GetContext(ctx context.Context) *CustomContext {
	customCtx, ok := ctx.Value(customCtxKey).(*CustomContext)
	if !ok {
		return nil
	}

	return customCtx
}
