/*
 * Copyright (c) 2010-2022 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "drawpool.h"
#include "declarations.h"
#include "painter.h"
#include <utility>

DrawPool g_drawPool;

void DrawPool::init()
{
    // Create Pools
    for (int8_t i = -1; ++i <= static_cast<uint8_t>(PoolType::UNKNOW);) {
        m_pools[i] = Pool::create(static_cast<PoolType>(i));
    }
}

void DrawPool::terminate()
{
    // Destroy Pools
    m_currentPool = nullptr;
    for (int_fast8_t i = -1; ++i <= static_cast<uint8_t>(PoolType::UNKNOW);) {
        delete m_pools[i];
    }
}

void DrawPool::draw()
{
    // Pre Draw
    for (const auto& pool : m_pools) {
        if (!pool->isEnabled() || !pool->hasFrameBuffer()) continue;

        const auto& pf = pool->toPoolFramed();
        if (pool->hasModification(true) && !pool->m_objects.empty()) {
            pf->m_framebuffer->bind(pf->m_dest, pf->m_src);
            for (auto& obj : pool->m_objects)
                drawObject(obj);
            pf->m_framebuffer->release();
        } else pool->free();
    }

    // Draw
    for (const auto& pool : m_pools) {
        if (!pool->isEnabled()) continue;

        if (pool->hasFrameBuffer()) {
            const auto* const pf = pool->toPoolFramed();

            if (pf->m_beforeDraw) pf->m_beforeDraw();
            pf->m_framebuffer->draw();
            if (pf->m_afterDraw) pf->m_afterDraw();
        } else {
            for (auto& obj : pool->m_objects) {
                drawObject(obj);
            }
        }

        pool->m_objects.clear();
    }
}

void DrawPool::drawObject(DrawObject& obj)
{
    if (obj.action) {
        obj.action();
        return;
    }

    const bool useGlobalCoord = !obj.buffer;
    auto& buffer = useGlobalCoord ? m_coordsBuffer : *obj.buffer->m_coords;

    if (useGlobalCoord) {
        if (obj.drawMethods.empty()) return;
        for (const auto* method : obj.drawMethods) {
            method->add(buffer, obj.drawMode);
            delete method;
        }
    }

    { // Set DrawState
        const auto& state = obj.state;

        if (state.texture) {
            state.texture->create();
            g_painter->setTexture(state.texture.get());
        }

        g_painter->setColor(state.color);
        g_painter->setOpacity(state.opacity);
        g_painter->setCompositionMode(state.compositionMode);
        g_painter->setBlendEquation(state.blendEquation);
        g_painter->setClipRect(state.clipRect);
        g_painter->setShaderProgram(state.shaderProgram);
        g_painter->setTransformMatrix(state.transformMatrix);
        if (state.action) state.action();
    }

    g_painter->drawCoords(buffer, obj.drawMode);

    if (useGlobalCoord)
        m_coordsBuffer.clear();
}

void DrawPool::addTexturedRect(const Rect& dest, const TexturePtr& texture, const Color& color)
{
    if (dest.isEmpty())
        return;

    addTexturedRect(dest, texture, Rect(Point(), texture->getSize()), color);
}

void DrawPool::addTexturedRect(const Rect& dest, const TexturePtr& texture, const Rect& src, const Color& color, DrawBufferPtr drawQueue)
{
    if (dest.isEmpty())
        return;

    m_currentPool->add(color, texture, new DrawRect(dest, src), DrawMode::TRIANGLE_STRIP, drawQueue);
}

void DrawPool::addTexturedRect(const Rect& dest, const TexturePtr& texture, const Rect& src, const Point& originalDest, const Color& color, DrawBufferPtr drawQueue)
{
    if (dest.isEmpty() || src.isEmpty())
        return;

    m_currentPool->add(color, texture, new DrawTextureRect(dest, src, originalDest), DrawMode::TRIANGLE_STRIP, drawQueue);
}

void DrawPool::addUpsideDownTexturedRect(const Rect& dest, const TexturePtr& texture, const Rect& src, const Color& color)
{
    if (dest.isEmpty() || src.isEmpty())
        return;

    m_currentPool->add(color, texture, new DrawUpsideDown(dest, src), DrawMode::TRIANGLE_STRIP);
}

void DrawPool::addTexturedRepeatedRect(const Rect& dest, const TexturePtr& texture, const Rect& src, const Color& color)
{
    if (dest.isEmpty() || src.isEmpty())
        return;

    m_currentPool->add(color, texture, new DrawRepatedRects(dest, src));
}

void DrawPool::addFilledRect(const Rect& dest, const Color& color)
{
    if (dest.isEmpty())
        return;

    m_currentPool->add(color, nullptr, new DrawFilledRect(dest));
}

void DrawPool::addFilledTriangle(const Point& a, const Point& b, const Point& c, const Color& color)
{
    if (a == b || a == c || b == c)
        return;

    m_currentPool->add(color, nullptr, new DrawTriangle(a, b, c));
}

void DrawPool::addBoundingRect(const Rect& dest, const Color& color, int innerLineWidth)
{
    if (dest.isEmpty() || innerLineWidth == 0)
        return;

    m_currentPool->add(color, nullptr, new DrawBoundingRect(dest, innerLineWidth));
}

void DrawPool::addAction(std::function<void()> action)
{
    m_currentPool->m_objects.push_back(DrawObject{ .state = NULL_STATE,.action = std::move(action) });
}

void DrawPool::use(const PoolType type)
{
    m_currentPool = get<Pool>(type);
    m_currentPool->resetState();
}

void DrawPool::use(const PoolType type, const Rect& dest, const Rect& src, const Color& colorClear)
{
    use(type);

    if (!m_currentPool->hasFrameBuffer())
        return;

    const auto& pool = m_currentPool->toPoolFramed();
    pool->m_dest = dest;
    pool->m_src = src;
    pool->m_framebuffer->m_colorClear = colorClear;
}
