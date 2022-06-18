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

#pragma once
#include <framework/graphics/painter.h>

enum class DrawMethodType
{
    RECT,
    TRIANGLE,
    REPEATED_RECT,
    BOUNDING_RECT,
    UPSIDEDOWN_RECT,
};

struct _DrawState
{
    ~_DrawState() { shaderProgram = nullptr; action = nullptr; }

    CompositionMode compositionMode{ CompositionMode::NORMAL };
    BlendEquation blendEquation{ BlendEquation::ADD };
    Rect clipRect;
    float opacity{ 1.f };
    PainterShaderProgram* shaderProgram{ nullptr };
    std::function<void()> action{ nullptr };
};

struct DrawMethod
{
    virtual void add(CoordsBuffer& buffer, DrawMode drawMode) const {};
    virtual void updateHash(size_t& methodhash) const {};
    virtual bool hasRefPoint() const { return false; };
    virtual bool isEqual(DrawMethod& method) const { return true; };
};

struct DrawBoundingRect : DrawMethod
{
    DrawBoundingRect(const Rect& dest, int innerLineWidth) : m_rect(dest), m_innerLineWidth(innerLineWidth) {}
    Rect m_rect;
    int m_innerLineWidth;

    void add(CoordsBuffer& buffer, DrawMode drawMode) const override
    {
        buffer.addBoudingRect(m_rect, m_innerLineWidth);
    }

    void updateHash(size_t& methodhash) const override
    {
        if (m_rect.isValid())
            stdext::hash_union(methodhash, m_rect.hash());
        if (m_innerLineWidth)
            stdext::hash_combine(methodhash, m_innerLineWidth);
    }
};

struct DrawRect : DrawMethod
{
    DrawRect(const Rect& dest, const Rect& src) : m_dest(dest), m_src(src) {}
    Rect m_dest, m_src;

    void add(CoordsBuffer& buffer, DrawMode drawMode) const override
    {
        if (drawMode == DrawMode::TRIANGLES)
            buffer.addRect(m_dest, m_src);
        else
            buffer.addQuad(m_dest, m_src);
    }

    void updateHash(size_t& methodhash) const override
    {
        if (m_dest.isValid()) stdext::hash_union(methodhash, m_dest.hash());
        if (m_src.isValid()) stdext::hash_union(methodhash, m_src.hash());
    }
};

struct DrawFilledRect : DrawMethod
{
    DrawFilledRect(const Rect& dest) : m_dest(dest) {}
    Rect m_dest;

    void add(CoordsBuffer& buffer, DrawMode drawMode) const override
    {
        buffer.addRect(m_dest);
    }

    void updateHash(size_t& methodhash) const override
    {
        if (m_dest.isValid()) stdext::hash_union(methodhash, m_dest.hash());
    }
};

struct DrawTextureRect : DrawRect
{
    DrawTextureRect(const Rect& dest, const Rect& src, const Point& originalDest) : DrawRect(dest, src), m_destP(originalDest) {}
    Point m_destP;

    bool hasRefPoint() const override { return true; };
};

struct DrawTriangle : DrawMethod
{
    DrawTriangle(const Point& a, const Point& b, const Point& c) : m_a(a), m_b(b), m_c(c) {}
    Point m_a, m_b, m_c;

    void add(CoordsBuffer& buffer, DrawMode drawMode) const override
    {
        buffer.addTriangle(m_a, m_b, m_c);
    }

    void updateHash(size_t& methodhash) const override
    {
        if (!m_a.isNull()) stdext::hash_union(methodhash, m_a.hash());
        if (!m_b.isNull()) stdext::hash_union(methodhash, m_b.hash());
        if (!m_c.isNull()) stdext::hash_union(methodhash, m_c.hash());
    }
};

struct DrawUpsideDown : DrawRect
{
    DrawUpsideDown(const Rect& dest, const Rect& src) : DrawRect(dest, src) {}
    void add(CoordsBuffer& buffer, DrawMode drawMode) const override
    {
        if (drawMode == DrawMode::TRIANGLES)
            buffer.addUpsideDownRect(m_dest, m_src);
        else
            buffer.addUpsideDownQuad(m_dest, m_src);
    }
};

struct DrawRepatedRects : DrawRect
{
    DrawRepatedRects(const Rect& dest, const Rect& src) : DrawRect(dest, src) {}
    void add(CoordsBuffer& buffer, DrawMode drawMode) const override
    {
        buffer.addRepeatedRects(m_dest, m_src);
    }
};

struct DrawObject
{
    ~DrawObject()
    {
        state.texture = nullptr;
        action = nullptr;
        buffer = nullptr;
    }

    Painter::PainterState state;
    DrawMode drawMode;
    std::vector<const DrawMethod*> drawMethods;
    DrawBufferPtr buffer;
    std::function<void()> action{ nullptr };
};
